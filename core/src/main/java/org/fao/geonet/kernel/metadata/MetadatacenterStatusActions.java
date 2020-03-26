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
import org.fao.geonet.repository.UserGroupRepository;
import org.fao.geonet.repository.specification.UserGroupSpecs;
import org.fao.geonet.util.WorkflowUtil;
import org.springframework.data.jpa.domain.Specifications;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static org.springframework.data.jpa.domain.Specifications.where;

public class MetadatacenterStatusActions extends AIVStatusActions {

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
        String changeMessage = status.getChangeMessage();
        // -- process the metadata record to set status
        int mid = metadata.getId();

        boolean isTemplate = metadata.getDataInfo().getType()
            .equals(MetadataType.TEMPLATE)
            || metadata.getDataInfo().getType()
            .equals(MetadataType.SUB_TEMPLATE);

        // templates need not be valid, other md must be valid to change
        // status to approved
        if (/*!currentStatusId.equals(statusId) && */statusChangeAllowedByUser(currentStatusId, statusId, metadata) && (isTemplate ||
            !(statusId.equals(StatusValue.Status.SUBMITTED_FOR_AGIV) || statusId.equals(StatusValue.Status.APPROVED_BY_AGIV) ||
                statusId.equals(StatusValue.Status.APPROVED)) || statusChangeAllowed(metadata))) {
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
            if (statusId.equals(StatusValue.Status.REJECTED_FOR_RETIRE) || statusId.equals(StatusValue.Status.REJECTED_FOR_REMOVE)) {
                MetadataStatus previousStatus = metadataStatusManager.getPreviousStatus(mid);
                if (previousStatus != null) {
                    previousStatus.getId().setChangeDate(new ISODate());
                    previousStatus.setChangeMessage(changeMessage);
                    notificationProperties.put("previousStatus", String.valueOf(previousStatus.getId().getStatusId()));
                    //metadataStatusManager.setStatusExt(previousStatus);
                    metadataStatusManager.setStatusExt(context, mid, previousStatus.getId().getStatusId(), new ISODate(), changeMessage);
                }
            } else {
                //metadataStatusManager.setStatusExt(status);
                metadataStatusManager.setStatusExt(context, mid, status.getId().getStatusId(), status.getId().getChangeDate(), status.getChangeMessage());
            }
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

    protected boolean changeAllowedByAdmin(String currentStatusId, String statusId) {
        boolean changeAllowed = true;
        switch (Integer.parseInt(statusId)) {
            case 0: //UNKNOWN
            case 6: //JUSTCREATED
                break;
            case 1: //DRAFT
            case 4: //SUBMITTED
            case 5: //REJECTED
                changeAllowed = false;
                break;
            case 2: //APPROVED
                if (currentStatusId.equals(StatusValue.Status.SUBMITTED) || currentStatusId.equals(StatusValue.Status.REJECTED) || currentStatusId.equals(StatusValue.Status.REJECTED_BY_AGIV) || currentStatusId.equals(StatusValue.Status.RETIRED_FOR_AGIV) || currentStatusId.equals(StatusValue.Status.REMOVED_FOR_AGIV) || currentStatusId.equals(StatusValue.Status.REJECTED_FOR_RETIRE) || currentStatusId.equals(StatusValue.Status.REJECTED_FOR_REMOVE)) {
                    changeAllowed = false;
                }
                break;
            case 3: //RETIRED
            case 13: //REJECTED_FOR_RETIRE
                if (!currentStatusId.equals(StatusValue.Status.RETIRED_FOR_AGIV)) {
                    changeAllowed = false;
                }
                break;
            case 7: //SUBMITTED_FOR_AGIV
                if (!currentStatusId.equals(StatusValue.Status.DRAFT)) {
                    changeAllowed = false;
                }
                break;
            case 8: //APPROVED_BY_AGIV
                if (!currentStatusId.equals(StatusValue.Status.DRAFT) && !currentStatusId.equals(StatusValue.Status.SUBMITTED_FOR_AGIV)) {
                    changeAllowed = false;
                }
                break;
            case 9: //REJECTED_BY_AGIV
                if (currentStatusId.equals(StatusValue.Status.DRAFT) || currentStatusId.equals(StatusValue.Status.APPROVED) || currentStatusId.equals(StatusValue.Status.RETIRED) || currentStatusId.equals(StatusValue.Status.SUBMITTED) || currentStatusId.equals(StatusValue.Status.REJECTED) ||
                    currentStatusId.equals(StatusValue.Status.APPROVED_BY_AGIV) || currentStatusId.equals(StatusValue.Status.RETIRED_FOR_AGIV) || currentStatusId.equals(StatusValue.Status.REMOVED_FOR_AGIV)) {
                    changeAllowed = false;
                }
                break;
            case 10: //RETIRED_FOR_AGIV
                if (!currentStatusId.equals(StatusValue.Status.APPROVED)) {
                    changeAllowed = false;
                }
                break;
            case 11: //REMOVED_FOR_AGIV
                if (currentStatusId.equals(StatusValue.Status.SUBMITTED_FOR_AGIV) ||
                    currentStatusId.equals(StatusValue.Status.APPROVED_BY_AGIV) ||
                    currentStatusId.equals(StatusValue.Status.RETIRED_FOR_AGIV)) {
                    changeAllowed = false;
                }
                break;
            case 12: //REMOVED
            case 14: //REJECTED_FOR_REMOVE
                if (!currentStatusId.equals(StatusValue.Status.REMOVED_FOR_AGIV)) {
                    changeAllowed = false;
                }
                break;
            default:
                break;
        }
        return changeAllowed;
    }

    protected boolean changeAllowedByReviewer(String currentStatusId, String statusId, boolean bIsDraft) {
        boolean changeAllowed = true;
        if (currentStatusId.equals(StatusValue.Status.SUBMITTED_FOR_AGIV) || currentStatusId.equals(StatusValue.Status.APPROVED_BY_AGIV) || currentStatusId.equals(StatusValue.Status.RETIRED_FOR_AGIV) || currentStatusId.equals(StatusValue.Status.REMOVED_FOR_AGIV)) {
            changeAllowed = false;
        } else {
            switch (Integer.parseInt(statusId)) {
                case 0: //UNKNOWN
                case 1: //DRAFT
                case 2: //APPROVED
                case 3: //RETIRED
                case 6: //JUSTCREATED
                case 8: //APPROVED_BY_AGIV
                case 9: //REJECTED_BY_AGIV
                case 12: //REMOVED
                case 13: //REJECTED_FOR_RETIRE
                case 14: //REJECTED_FOR_REMOVE
                    changeAllowed = false;
                    break;
                case 4: //SUBMITTED
                case 7: //SUBMITTED_FOR_AGIV
                    if (currentStatusId.equals(StatusValue.Status.APPROVED) || currentStatusId.equals(StatusValue.Status.RETIRED)) {
                        changeAllowed = false;
                    }
                    break;
                case 5: //REJECTED
                    if (currentStatusId.equals(StatusValue.Status.APPROVED) || currentStatusId.equals(StatusValue.Status.RETIRED) || currentStatusId.equals(StatusValue.Status.REJECTED_BY_AGIV)) {
                        changeAllowed = false;
                    }
                    break;
                case 10: //RETIRED_FOR_AGIV
                    if (bIsDraft || currentStatusId.equals(StatusValue.Status.RETIRED) || currentStatusId.equals(StatusValue.Status.REMOVED_FOR_AGIV)) {
                        changeAllowed = false;
                    }
                case 11: //REMOVED_FOR_AGIV
                    if (bIsDraft || currentStatusId.equals(StatusValue.Status.RETIRED_FOR_AGIV)) {
                        changeAllowed = false;
                    }
                    break;
                default:
                    break;
            }
        }

        return changeAllowed;
    }

    protected boolean changeAllowedByEditor(String currentStatusId, String statusId, AbstractMetadata metadata, AccessManager accessManager) throws Exception {
        boolean changeAllowed = true;
        if (!accessManager.isOwner(context, String.valueOf(metadata.getId())) || currentStatusId.equals(StatusValue.Status.SUBMITTED) || currentStatusId.equals(StatusValue.Status.SUBMITTED_FOR_AGIV)) {
            changeAllowed = false;
        } else {
            switch (Integer.parseInt(statusId)) {
                case 0: //UNKNOWN
                case 1: //DRAFT
                case 2: //APPROVED
                case 3: //RETIRED
                case 5: //REJECTED
                case 6: //JUSTCREATED
                case 7: //SUBMITTED_FOR_AGIV
                case 8: //APPROVED_BY_AGIV
                case 9: //REJECTED_BY_AGIV
                case 10: //RETIRED_FOR_AGIV
                case 11: //REMOVED_FOR_AGIV
                case 12: //REMOVED
                case 13: //REJECTED_FOR_RETIRE
                case 14: //REJECTED_FOR_REMOVE
                    changeAllowed = false;
                    break;
                case 4: //SUBMITTED
                    if (!(currentStatusId.equals(StatusValue.Status.DRAFT) || currentStatusId.equals(StatusValue.Status.REJECTED) || currentStatusId.equals(StatusValue.Status.REJECTED_BY_AGIV))) {
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
                case 0: //UNKNOWN
                    break;
                case 1: //DRAFT
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    break;
                case 2: //APPROVED
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                case 3: //RETIRED
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                case 4: //SUBMITTED
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    break;
                case 5: //REJECTED
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    break;
                case 6: //JUSTCREATED
                    break;
                case 7: //SUBMITTED_FOR_AGIV
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                case 8: //APPROVED_BY_AGIV
                    if (session.getProfile().equals(Profile.Administrator) && currentStatusId.equals(StatusValue.Status.DRAFT)) {
                        changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                        changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    }
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                case 9: //REJECTED_BY_AGIV
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                case 10: //RETIRED_FOR_AGIV
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                case 11: //REMOVED_FOR_AGIV
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                case 12: //REMOVED
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    recordsToBeDeleted.put(String.valueOf(metadata.getId()), metadata.getUuid());
                    break;
                case 13: //REJECTED_FOR_RETIRE
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                case 14: //REJECTED_FOR_REMOVE
                    changedMetadataIdsToInformEditors.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformReviewers.put(metadata.getUuid(), notificationProperties);
                    changedMetadataIdsToInformAdministrators.put(metadata.getUuid(), notificationProperties);
                    break;
                default:
                    break;
            }
        }
    }

    protected void processList(ServiceContext context, String replyTo, String replyToDescr, List<Object[]> contentUsers, String subject, String statusId,
                               String changeDate, String changeMessage, Map<String, Map<String, String>> metadataMap, List<String> emailMetadataIdList)
        throws Exception {
        processList(context, replyTo, replyToDescr, contentUsers, subject, statusId, changeDate, changeMessage, metadataMap, emailMetadataIdList, WorkflowUtil.getNodeType(context));
    }
}
