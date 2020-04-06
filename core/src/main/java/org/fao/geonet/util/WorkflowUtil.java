//=============================================================================
//===
//=== ThreadUtils
//===
//=============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//=============================================================================

package org.fao.geonet.util;

import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.*;
import org.fao.geonet.kernel.metadata.StatusActionsFactory;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.UserGroupRepository;
import org.fao.geonet.repository.UserRepository;
import org.fao.geonet.repository.specification.UserGroupSpecs;
import org.fao.geonet.utils.IO;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.springframework.data.jpa.domain.Specifications;

import java.io.File;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.fao.geonet.kernel.setting.Settings.*;
import static org.fao.geonet.kernel.setting.Settings.SYSTEM_FEEDBACK_MAILSERVER_TLS;
import static org.springframework.data.jpa.domain.Specifications.where;

public class WorkflowUtil {

    private static String FS = File.separator;
    /**
     * Checks if a group has the workflow enabled.
     *
     * @param groupName Group name
     * @return
     */
    public static boolean isGroupWithEnabledWorkflow(String groupName) {
        SettingManager settingManager = ApplicationContextHolder.get().getBean(SettingManager.class);

        boolean isMdWorkflowEnable = settingManager.getValueAsBool(Settings.METADATA_WORKFLOW_ENABLE);
        String groupMatchingRegex = settingManager.getValue(Settings.METADATA_WORKFLOW_DRAFT_WHEN_IN_GROUP);

        if (isMdWorkflowEnable && !StringUtils.isEmpty(groupMatchingRegex)) {
            final Pattern pattern = Pattern.compile(groupMatchingRegex);
            final Matcher matcher = pattern.matcher(groupName);
            return matcher.find();
        } else {
            return false;
        }
    }

    /**
     * Inform content users of metadata records in list
     *
     * @param context      The service context
     * @return
     */
    public static String getNodeType(ServiceContext context) {
        String nodeType = "";
        StatusActionsFactory saf = context.getBean(StatusActionsFactory.class);
        if (saf.getClassName().endsWith("MetadatacenterStatusActions")) {
            nodeType = "Metadatacenter";
        }
        if (saf.getClassName().endsWith("GeopuntStatusActions")) {
            nodeType = "Geopunt";
        }
        return nodeType;
    }

    /**
     * Send email to a list of users. The list of users is defined based on
     * the notification level of the status. See {@link StatusValueNotificationLevel}.
     *
     * @param context
     * @param status
     * @param changedMetadataIdsToInformEditors
     * @param changedMetadataIdsToInformReviewers
     * @param changedMetadataIdsToInformAdministrators
     * @throws Exception
     */
    public static void notify(ServiceContext context, MetadataStatus status, Map<String, Map<String, String>> changedMetadataIdsToInformEditors, Map<String, Map<String, String>> changedMetadataIdsToInformReviewers, Map<String, Map<String, String>> changedMetadataIdsToInformAdministrators) throws Exception {
        String statusId = status.getId().getStatusId() + "";
        String changeMessage = status.getChangeMessage();
        List<String> emailMetadataIdList = new ArrayList<String>();
        if (changedMetadataIdsToInformAdministrators!=null && changedMetadataIdsToInformAdministrators.size() > 0) {
            informContentUsers(context, changedMetadataIdsToInformAdministrators,
                changeMessage, Profile.Administrator, statusId, emailMetadataIdList, null);
        }
        if (changedMetadataIdsToInformReviewers!=null && changedMetadataIdsToInformReviewers.size() > 0) {
            informContentUsers(context, changedMetadataIdsToInformReviewers,
                changeMessage, Profile.Reviewer, statusId, emailMetadataIdList, null);
        }
        if (changedMetadataIdsToInformEditors!=null && changedMetadataIdsToInformEditors.size() > 0) {
            informContentUsers(context, changedMetadataIdsToInformEditors,
                changeMessage, Profile.Editor, statusId, emailMetadataIdList, null);
        }
    }

    /**
     * Inform content users of metadata records in list
     *
     * @param context      The service context
     * @param metadataMap         The selected set of metadata records
     * @param changeMessage       Message supplied by the user that set the status
     * @param profile             Profile of users to be informed
     * @param statusId            New status
     * @param emailMetadataIdList List for adding email adresses to sent to the metadata info
     */
    public static void informContentUsers(ServiceContext context, Map<String, Map<String, String>> metadataMap,
                                    String changeMessage, Profile profile, String statusId, List<String> emailMetadataIdList, List<Object[]> contentUsers) throws Exception {

        UserRepository userRepository = context.getBean(UserRepository.class);
        // --- get content reviewers (sorted on content reviewer userid)
        if (contentUsers==null || contentUsers.isEmpty()) {
            if (profile.equals(Profile.Administrator)) {
                contentUsers = userRepository.getContentAdmins(metadataMap.keySet());
            } else {
                contentUsers = userRepository.getContentUsers(metadataMap.keySet(), profile.ordinal());
            }
        }

        SettingManager sm = context.getBean(SettingManager.class);
        String siteName = sm.getSiteName();
        String from = sm.getValue(Settings.SYSTEM_FEEDBACK_EMAIL);

        UserSession us = context.getUserSession();
        String replyToDescr = null;
        String replyTo = us.getEmailAddr();
        if (replyTo != null) {
            replyToDescr = us.getName() + " " + us.getSurname();
        } else {
            replyTo = from;
            replyToDescr = siteName;
        }

        processList(context, replyTo, replyToDescr, contentUsers, statusId, changeMessage, metadataMap, emailMetadataIdList, getNodeType(context));
    }

    /**
     * Process the users and metadata records for emailing notices.
     */
    @SuppressWarnings("unchecked")
    private static void processList(ServiceContext context, String replyTo, String replyToDescr, List<Object[]> contentUsers, String status,
                               String changeMessage, Map<String, Map<String, String>> metadataMap, List<String> emailMetadataIdList, String nodeType)
        throws Exception {
        Set<String> metadataIds = new HashSet<String>();
        String currentUserId = null;
        String userId = null;
        String currentEmail = null;
        Iterator<Object[]> recordsIterator = contentUsers.iterator();
        Element root = null;
        while (recordsIterator.hasNext()) {
            Object[] record = recordsIterator.next();
            //select m.id as metadataid, m.uuid as metadatauuid, u.id as userid, u.name as name, u.surname as surname, u.email
            String metadataId = String.valueOf(record[0]);
            String metadataUUID = String.valueOf(record[1]);
            userId = String.valueOf(record[2]);
            if (currentUserId == null) {
                currentUserId = userId;
                currentEmail = String.valueOf(record[5]);
                if (currentEmail != null) {
                    currentEmail = currentEmail.toLowerCase();
                }
                root = getNewRootElement(context, context.getUserSession().getUserIdAsInt(), "user", "group", status, changeMessage, nodeType);
            } else if (!currentUserId.equals(userId)) {
                if (StringUtils.isNotBlank(currentEmail) && metadataIds.size() > 0) {
                    sendEmail(context, currentEmail, replyTo, replyToDescr, root);
                    metadataIds.clear();
                }
                currentUserId = userId;
                currentEmail = String.valueOf(record[5]);
                if (currentEmail != null) {
                    currentEmail = currentEmail.toLowerCase();
                }
                root = getNewRootElement(context, context.getUserSession().getUserIdAsInt(), "user", "group", status, changeMessage, nodeType);
            }
            if (StringUtils.isNotBlank(currentEmail) && !emailMetadataIdList.contains(currentEmail + "_" + metadataId)) {
                emailMetadataIdList.add(currentEmail + "_" + metadataId);
                metadataIds.add(metadataId);
                addMetadataContent(context, root, metadataUUID, metadataMap.get(metadataUUID).get("title").toString(), metadataMap.get(metadataUUID).get("currentStatus"), metadataMap.get(metadataUUID).get("previousStatus"));
            }
        }

        if (StringUtils.isNotBlank(currentEmail) && metadataIds.size() > 0) {
            sendEmail(context, currentEmail, replyTo, replyToDescr, root);
        }
    }

    public static Element getNewRootElement(ServiceContext context, int userId, String userElementName, String groupElementName, String status, String changeMessage, String nodeType) {
        SettingManager sm = context.getBean(SettingManager.class);
        String baseUrl = sm.getBaseURL();
        String siteUrl = sm.getSiteURL(context);
        String siteName = sm.getSiteName();

        Element root = new Element("root");
        addUserContent(context, root, userId, userElementName, groupElementName);
        root.addContent(new Element("node").setText(nodeType));
        root.addContent(new Element("baseUrl").setText(baseUrl));
        root.addContent(new Element("siteUrl").setText(siteUrl));
        root.addContent(new Element("metadatacenter").setText(siteName));
        root.addContent(new Element("status").setText(status));
        root.addContent(new Element("changeMessage").setText(changeMessage));
        return root;
    }

    public static void addUserContent(ServiceContext context, Element root, int userId, String userElementName, String groupElementName) {
        User user = context.getBean(UserRepository.class).findOne(userId);
        if (user != null) {
            Element userElement = new Element(userElementName);
            userElement.addContent(new Element("surname").setText(user.getSurname()));
            userElement.addContent(new Element("name").setText(user.getName()));
            root.addContent(userElement);
            Element groupElement = new Element(groupElementName);
            // Retrieve user groups
            String groupName = null;
            UserGroupRepository userGroupRepository = context.getBean(UserGroupRepository.class);
            Specifications spec = where(UserGroupSpecs.hasProfile(user.getProfile())).and(UserGroupSpecs.hasUserId(userId));
            List<UserGroup> userGroups = userGroupRepository.findAll(spec);
            for (UserGroup ug : userGroups) {
                Group g = ug.getGroup();
                groupName = (groupName == null ? g.getName() : groupName + ", " + g.getName());
            }
            if (groupName==null) {
                groupName = context.getUserSession().getOrganisation();
            }
            groupElement.setText(groupName);
            root.addContent(groupElement);
        }
    }

    public static void addMetadataContent(ServiceContext context, Element root, String metadataUUID, String title, String currentStatus, String previousStatus) {
        Element metadata = new Element("metadata");
        root.addContent(metadata);
        SettingManager sm = context.getBean(SettingManager.class);
        metadata.addContent(new Element("url").setText(sm.getSiteURL(context) + "catalog.search#/metadata/" + metadataUUID));
        metadata.addContent(new Element("title").setText(title));
        metadata.addContent(new Element("currentStatus").setText(currentStatus));
        if (previousStatus != null) {
            metadata.addContent(new Element("previousStatus").setText(previousStatus));
        }
    }

    public static void sendEmail(ServiceContext context, String sendTo, String replyTo, String replyToDescr, Element params)
        throws Exception {
        SettingManager sm = context.getBean(SettingManager.class);
        String siteName = sm.getSiteName();
        String host = sm.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_HOST);
        String port = sm.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_PORT);
        String from = sm.getValue(Settings.SYSTEM_FEEDBACK_EMAIL);
        String username = sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_USERNAME);
        String password = sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_PASSWORD);
        boolean useSSL = Boolean.parseBoolean(sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_SSL));
        boolean useTLS = Boolean.parseBoolean(sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_TLS));
        boolean emailNotes = true;

        if (host.length() == 0) {
            context.error("Mail server host not configured, email notifications won't be sent.");
            emailNotes = false;
        }

        if (port.length() == 0) {
            context.error("Mail server port not configured, email notifications won't be sent.");
            emailNotes = false;
        }

        if (from.length() == 0) {
            context.error("Mail feedback address not configured, email notifications won't be sent.");
            emailNotes = false;
        }

        if (!emailNotes) {
            context.info("Would send email with message grablock service but no email server configured");
        } else {
            String styleSheet = context.getAppPath() + FS + Geonet.Path.STYLESHEETS + FS + Geonet.File.STATUS_CHANGE_EMAIL;
            Element emailElement = Xml.transform(params, IO.toPath(styleSheet));
            MailSender sender = new MailSender(context);
            sender.sendWithReplyTo(host, Integer.parseInt(port), username, password, useSSL, useTLS, true, from, siteName, sendTo, null, replyTo, replyToDescr, emailElement.getChildText("subject"),
                emailElement.getChildText("message"));
        }
    }

}
