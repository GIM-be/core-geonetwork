/**
 * Copyright (C) 2013 GeoNetwork
 *
 * This file is part of GeoNetwork
 *
 * GeoNetwork is free software: you can redistribute it and/or modify it under the terms of the GNU
 * General Public License as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * GeoNetwork is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with GeoNetwork.  If not,
 * see <http://www.gnu.org/licenses/>.
 */

package org.fao.geonet.services.harvesting.notifier;

import org.apache.commons.mail.EmailException;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.api.exception.NotAllowedException;
import org.fao.geonet.api.exception.ResourceNotFoundException;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.Group;
import org.fao.geonet.domain.Profile;
import org.fao.geonet.domain.User;
import org.fao.geonet.domain.UserGroupId_;
import org.fao.geonet.kernel.HarvestValidationEnum;
import org.fao.geonet.kernel.harvest.harvester.AbstractHarvester;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.GroupRepository;
import org.fao.geonet.repository.UserRepository;
import org.fao.geonet.repository.specification.UserGroupSpecs;
import org.fao.geonet.util.MailUtil;
import org.fao.geonet.utils.Log;
import org.jdom.Element;
import org.springframework.context.ApplicationContext;
import org.springframework.web.bind.annotation.PathVariable;

import com.google.common.collect.Lists;

import static org.springframework.data.jpa.domain.Specifications.where;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import jeeves.server.context.ServiceContext;

/**
 * This class send an email after a harvester has been run
 *
 * @author Maria Arias de Reyna
 */
public class SendNotification {

    /**
     * Launches the notification manager
     */
    public static void process(ServiceContext context, Element element,
                               @SuppressWarnings("rawtypes") AbstractHarvester abstractHarvester)
        throws EmailException {
        GeonetContext gc = (GeonetContext) context
            .getHandlerContext(Geonet.CONTEXT_NAME);
        SettingManager settings = gc.getBean(SettingManager.class);
        notifyByMail(settings, element, abstractHarvester);
    }

    /**
     * Send the mail
     */
    private static void notifyByMail(SettingManager settings, Element element, @SuppressWarnings("rawtypes") AbstractHarvester ah) {

        if (!settings.getValueAsBool(Settings.SYSTEM_HARVESTING_MAIL_ENABLED)) {
            return;
        }

        String receiver = settings.getValue(Settings.SYSTEM_HARVESTING_MAIL_RECIPIENT);
        List<String> toAddress = new ArrayList<String>();
        List<String> bccAddress = new ArrayList<String>();
        boolean bToAddressSet = false;

        try {
            String groupOwnerEmail = ah.getGroupOwnerEmail();
            if (groupOwnerEmail != null && !groupOwnerEmail.trim().isEmpty()) {
                toAddress.add(groupOwnerEmail);
                bToAddressSet = true;
            }
            String ownerEmail = ah.getOwnerEmail();
            if (ownerEmail != null && !ownerEmail.trim().isEmpty()) {
                if (bToAddressSet) {
                    if (!bccAddress.contains(ownerEmail)) {
                        bccAddress.add(ownerEmail);
                    }
                } else {
                    toAddress.add(ownerEmail);
                    bToAddressSet = true;
                }
            }
        } catch (Exception e1) {
            Log.error(Geonet.HARVESTER, e1.getMessage(), e1);
        }

        if (receiver != null && !receiver.trim().isEmpty()) {
            if (bToAddressSet) {
                if (!bccAddress.contains(receiver)) {
                    bccAddress.add(receiver);
                }
            } else {
                toAddress.add(receiver);
            }
        }

        String subject = settings.getValue(Settings.SYSTEM_HARVESTING_MAIL_SUBJECT);

        String htmlMessage = settings.getValue(Settings.SYSTEM_HARVESTING_MAIL_TEMPLATE);

        Element info = element.getChild("info");

        // We should always get a info report BTW
        if (info != null) {
            // Success, but with warnings or clean?
            Element result = (Element) info.getChildren().get(0);

            // switch between normal and error template
            if (info.getChildren("error").size() > 0) {
                // Error, Level 3, let's check it:
                if (!settings.getValueAsBool(Settings.SYSTEM_HARVESTING_MAIL_LEVEL3)) {
                    return;
                }
                htmlMessage = settings.getValue(Settings.SYSTEM_HARVESTING_MAIL_TEMPLATE_ERROR);
                Element error = (Element) info.getChildren("error").get(0);
                String errorMsg = error.getChildText("message");
                // do not convert it to html, dangerous!
                errorMsg = errorMsg.replace("<", " ");

                errorMsg += extractWarningsTrace(info);

                htmlMessage = htmlMessage.replace("$$errorMsg$$", errorMsg);

            } else {

                Element harvesterErrors = result.getChild("errors");

                if (harvesterErrors != null && harvesterErrors.getChildren().size() > 0) {
                    // Success with warnings, Level 2, let's check it:
                    if (!settings.getValueAsBool(Settings.SYSTEM_HARVESTING_MAIL_LEVEL2)) {
                        return;
                    }

                    htmlMessage = settings.getValue(Settings.SYSTEM_HARVESTING_MAIL_TEMPLATE_ERROR);

                    String errorMsg = extractWarningsTrace(result);

                    htmlMessage = htmlMessage.replace("$$errorMsg$$", errorMsg);

                    subject = "Errors in harvester: " + subject;

                } else {
                    int iUnretrievable = 0;
                    int iDoesNotValidate = 0;
                    String sUnretrievable = result.getChildText("unretrievable");
                    if (sUnretrievable != null) {
                        iUnretrievable = Integer.parseInt(sUnretrievable);
                    }
                    String sDoesNotValidate = result.getChildText("doesNotValidate");
                    if (sDoesNotValidate != null) {
                        iDoesNotValidate = Integer.parseInt(sDoesNotValidate);
                    }
                    if (iUnretrievable + iDoesNotValidate > 0) {
                        // Success with warnings, Level 2, let's check it:
                        if (!settings.getValueAsBool(Settings.SYSTEM_HARVESTING_MAIL_LEVEL2)) {
                            return;
                        }
                        htmlMessage = settings.getValue(Settings.SYSTEM_HARVESTING_MAIL_TEMPLATE_WARNING);
                        subject = "Warnings in harvester: " + subject;
                    } else {
                        // Success!! Level 1, let's check it:
                        if (!settings.getValueAsBool(Settings.SYSTEM_HARVESTING_MAIL_LEVEL1)) {
                            return;
                        }
                        subject = "Succesfull harvester: " + subject;
                    }

                }
            }
            String[] values = new String[]{"total", "added", "updated",
                "removed", "unchanged", "unretrievable", "doesNotValidate"};

            for (String value : values) {
                htmlMessage = replace(result, htmlMessage, value);
                subject = replace(result, subject, value);
            }

            String logfile = result.getChildText("logfile");
            if (logfile != null) {
                htmlMessage = htmlMessage.replace("$$logURL$$",
                    settings.getSiteURL("dut") + "/admin.harvester.log?file=" + logfile.replaceAll("\\\\", "/"));
            }
        }

        htmlMessage = htmlMessage.replace("$$harvesterName$$", ah.getParams().getName());
        subject = subject.replace("$$harvesterName$$", ah.getParams().getName());

        htmlMessage = htmlMessage.replace("$$harvesterType$$", ah.getType());
        subject = subject.replace("$$harvesterType$$", ah.getType());

        htmlMessage = htmlMessage.replace("$$harvestValidate$$", getHarvestValidationLabel(ah.getParams().getValidate()));
        subject = subject.replace("$$harvestValidate$$", getHarvestValidationLabel(ah.getParams().getValidate()));

        MailUtil.sendHtmlMail(toAddress, bccAddress, subject, htmlMessage, settings);
    }

    @SuppressWarnings("unused")
    private static List<User> getGroupUsers(Integer groupId) {
        ApplicationContext applicationContext = ApplicationContextHolder.get();
        GroupRepository groupRepository = applicationContext.getBean(GroupRepository.class);
        final Group group = groupRepository.findOne(groupId);

        if (group != null) {
            UserRepository userRepository = applicationContext.getBean(UserRepository.class);
            return userRepository.findAllUsersInUserGroups(
                UserGroupSpecs.hasGroupId(groupId));
        }
        return null;
    }

    /**
     * @param result
     * @return
     */
    private static String extractWarningsTrace(Element result) {
        StringBuffer errorMsg = new StringBuffer("<ul>");

        for (Object o : result.getChildren("errors")) {
            Element errors = ((Element) o);
            for (Object a : errors.getChildren("error")) {
                Element error = ((Element) a);
                String desc = error.getChildText("description");
                String hint = error.getChildText("hint");
                // String trace = getErrorTrace(error);

                // do not convert it to html, dangerous!
                errorMsg = errorMsg.append("<li><p><strong>'")
                    .append(desc)
                    .append("'</strong>: ")
                    .append(hint)
                    //.append("</p><p>")
                    //.append(trace)
                    .append("</p></li>");
            }
        }
        errorMsg.append("</ul>");
        return errorMsg.toString();
    }

    /**
     * @param error
     * @return
     */
    private static String getErrorTrace(Element error) {
        String trace = "";
        for (Object e : error.getChildren("error")) {
            Element error_ = ((Element) e);
            trace = error_.getChildText("message");
        }
        return trace.replace("<", " ");
    }

    /**
     * Helps in the transformation of template to message
     */
    private static String replace(Element element, String htmlMessage,
                                  String value) {
        String tmp = element.getChildText(value);
        if (tmp == null) {
            return htmlMessage.replace("$$" + value + "$$", "0");
        } else {
            return htmlMessage.replace("$$" + value + "$$", tmp);
        }
    }

    private static String getHarvestValidationLabel(HarvestValidationEnum validation) {
        switch (validation) {
            case NOVALIDATION:
                return "No validation";
            case XSDVALIDATION:
                return "XSD validation only";
            case SCHEMATRONVALIDATION:
                return "Schematron and XSD validation";
            default:
                return "Unknown";
        }
    }
}
