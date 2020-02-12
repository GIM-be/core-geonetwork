//=============================================================================
//===	Copyright (C) 2001-2011 Food and Agriculture Organization of the
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
//==============================================================================

package org.fao.geonet.kernel.metadata;

import jeeves.server.context.ServiceContext;
import org.fao.geonet.domain.*;
import org.fao.geonet.kernel.AccessManager;

import java.util.List;
import java.util.Map;
import java.util.Set;

public class GeopuntStatusActions extends AIVStatusActions {

    /**
     * Constructor.
     */
    public GeopuntStatusActions() {
    }

    /**
     * This apply specific rules depending on status change.
     *
     * @param status
     * @param metadata
     * @param currentStatusId
     * @param unchanged
     * @param notificationProperties
     * @throws Exception
     */
    protected void applyRulesForStatusChange(MetadataStatus status, AbstractMetadata metadata, String currentStatusId, Set<Integer> unchanged, Map<String, String> notificationProperties) throws Exception {
        String statusId = status.getId().getStatusId() + "";
        // -- process the metadata record to set status
        int mid = metadata.getId();

        boolean isTemplate = metadata.getDataInfo().getType()
            .equals(MetadataType.TEMPLATE)
            || metadata.getDataInfo().getType()
            .equals(MetadataType.SUB_TEMPLATE);

        // templates need not be valid, other md must be valid to change
        // status to approved
        if (/*!currentStatusId.equals(statusId) && */statusChangeAllowedByUser(currentStatusId, statusId, metadata) && (isTemplate ||
            !statusId.equals(StatusValue.Status.APPROVED) || statusChangeAllowed(metadata))) {
            if (context.isDebugEnabled()) {
                context.debug("Change status of metadata with uuid " + metadata.getUuid()
                    + " from " + currentStatusId + " to " + statusId);
            }
            if (statusId.equals(StatusValue.Status.APPROVED)) {
                if (isTemplate && (session.getProfile().equals(Profile.Reviewer) || session.getProfile().equals(Profile.Administrator))) {
//							setAllOperationsForUserGroup(String.valueOf(mid));
                    setAllOperations(String.valueOf(mid));
                } else {
                    setAllOperations(String.valueOf(mid));
                }
            } else if (statusId.equals(StatusValue.Status.RETIRED)) {
                unsetAllOperations(mid);
            }
            metadataStatusManager.setStatusExt(status);
        } else {
            // TODO Make difference between unchanged records for reason of same status and for reason of insufficient rights
            unchanged.add(mid);
            if (context.isDebugEnabled()) {
                context.debug("Status change not allowed for metadata with uuid "
                    + metadata.getUuid() + " from " + currentStatusId + " to "
                    + statusId);
            }
        }
    }

    /**
     * This checks if the status can be set depending on the current status and user profile
     *
     * @param currentStatusId
     * @param statusId
     * @param metadata
     * @return
     * @throws Exception
     */
    @Override
    public boolean statusChangeAllowedByUser(String currentStatusId, String statusId,
                                             AbstractMetadata metadata) throws Exception {
        AccessManager accessManager = context.getBean(AccessManager.class);
        boolean changeAllowed = accessManager.canEdit(context, String.valueOf(metadata.getId()));
        if (changeAllowed) {
            if (session.getProfile() == (Profile.Administrator)) {
                changeAllowed = changeAllowedByAdmin(currentStatusId, statusId);
            } else if (session.getProfile() == Profile.Reviewer) {
                changeAllowed = changeAllowedByReviewer(currentStatusId, statusId);
            } else if (session.getProfile() == Profile.Editor) {
                changeAllowed = changeAllowedByEditor(currentStatusId, statusId, accessManager, metadata);
            }
        }
        return changeAllowed;
    }

    private boolean changeAllowedByAdmin(String currentStatusId, String statusId) {
        boolean changeAllowed = true;
        switch (Integer.parseInt(statusId)) {
            case 1: //DRAFT
            case 4: //SUBMITTED
            case 5: //REJECTED
                changeAllowed = false;
                break;
            case 2: //APPROVED
                if (currentStatusId.equals(StatusValue.Status.SUBMITTED) || currentStatusId.equals(StatusValue.Status.REJECTED)) {
                    changeAllowed = false;
                }
                break;
            case 3: //RETIRED
            case 6: //JUSTCREATED
                break;
            default:
                break;
        }
        return changeAllowed;
    }

    private boolean changeAllowedByReviewer(String currentStatusId, String statusId) {
        boolean changeAllowed = true;
        switch (Integer.parseInt(statusId)) {
            case 1: //DRAFT
            case 6: //JUSTCREATED
                changeAllowed = false;
                break;
            case 2: //APPROVED
                break;
            case 3: //RETIRED
                if (!currentStatusId.equals(StatusValue.Status.APPROVED)) {
                    changeAllowed = false;
                }
                break;
            case 4: //SUBMITTED
            case 5: //REJECTED
                if (currentStatusId.equals(StatusValue.Status.APPROVED) || currentStatusId.equals(StatusValue.Status.RETIRED)) {
                    changeAllowed = false;
                }
                break;
            default:
                break;
        }
        return changeAllowed;
    }

    private boolean changeAllowedByEditor(String currentStatusId, String statusId, AccessManager accessManager, AbstractMetadata metadata) throws Exception {
        boolean changeAllowed = true;
        if (!accessManager.isOwner(context, String.valueOf(metadata.getId())) || currentStatusId.equals(StatusValue.Status.SUBMITTED)) {
            changeAllowed = false;
        } else {
            switch (Integer.parseInt(statusId)) {
                case 1: //DRAFT
                case 2: //APPROVED
                case 3: //RETIRED
                case 5: //REJECTED
                case 6: //JUSTCREATED
                    changeAllowed = false;
                    break;
                case 4: //SUBMITTED
                    if (!(currentStatusId.equals(StatusValue.Status.DRAFT) || currentStatusId.equals(StatusValue.Status.REJECTED))) {
                        changeAllowed = false;
                    }
                    break;
                default:
                    break;
            }
        }
        return changeAllowed;
    }

    protected void getUserToNotify(String statusId, AbstractMetadata metadata, String currentStatusId, Map<String, String> notificationProperties, Map<String, String> recordsToBeDeleted, Map<String, Map<String, String>> changedMetadataIdsToInformEditors, Map<String, Map<String, String>> changedMetadataIdsToInformReviewers, Map<String, Map<String, String>> changedMetadataIdsToInformAdministrators) throws Exception {
        if (!statusId.equals(StatusValue.Status.APPROVED)) {
            notificationProperties.put("title", metadataUtils.extractTitle(metadata.getDataInfo().getSchemaId(), metadata.getXmlData(false)));
            notificationProperties.put("currentStatus", currentStatusId);
            switch (Integer.parseInt(statusId)) {
                case 1: //DRAFT
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    break;
                case 2: //APPROVED
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                case 3: //RETIRED
                case 5: //REJECTED
                case 4: //SUBMITTED
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    break;
                case 6: //JUSTCREATED
                    break;
                default:
                    break;
            }
        }
    }

    protected void processList(ServiceContext context, String replyTo, String replyToDescr, List<Object[]> contentUsers, String subject, String statusId,
                               String changeDate, String changeMessage, Map<String, Map<String, String>> metadataMap, List<String> emailMetadataIdList)
        throws Exception {
        processList(context, replyTo, replyToDescr, contentUsers, subject, statusId, changeDate, changeMessage, metadataMap, emailMetadataIdList, "geopunt");
    }
}
