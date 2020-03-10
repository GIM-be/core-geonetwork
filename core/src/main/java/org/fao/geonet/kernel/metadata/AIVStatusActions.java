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

import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.Constants;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.*;
import org.fao.geonet.events.md.MetadataStatusChanged;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.GeonetworkDataDirectory;
import org.fao.geonet.kernel.datamanager.IMetadataManager;
import org.fao.geonet.kernel.datamanager.IMetadataStatus;
import org.fao.geonet.kernel.datamanager.IMetadataUtils;
import org.fao.geonet.kernel.datamanager.IMetadataValidator;
import org.fao.geonet.kernel.datamanager.draft.DraftMetadataManager;
import org.fao.geonet.kernel.mef.MEFLib;
import org.fao.geonet.kernel.search.SearchManager;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.lib.Lib;
import org.fao.geonet.repository.MetadataValidationRepository;
import org.fao.geonet.repository.UserGroupRepository;
import org.fao.geonet.repository.UserRepository;
import org.fao.geonet.util.MailSender;
import org.fao.geonet.utils.BinaryFile;
import org.fao.geonet.utils.IO;
import org.fao.geonet.utils.Log;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import java.util.regex.Pattern;

import static org.fao.geonet.kernel.setting.Settings.*;
import static org.fao.geonet.repository.specification.UserGroupSpecs.hasUserId;

public abstract class AIVStatusActions implements StatusActions {

    public static final Pattern metadataLuceneField = Pattern.compile("\\{\\{index:([^\\}]+)\\}\\}");
    private static String FS = File.separator;
    protected ServiceContext context;
    protected String language;
    protected DataManager dm;
    @Autowired
    protected IMetadataUtils metadataUtils;
    protected String baseUrl;
    protected String siteUrl;
    protected String siteName;
    protected UserSession session;
    protected boolean emailNotes = true;
    protected IMetadataStatus metadataStatusManager;
    boolean useSSL, useTLS;
    private SettingManager sm;
    private String host, port, username, password, from, replyTo, replyToDescr;
    private IMetadataValidator metadataValidator;
    private MetadataValidationRepository metadataValidationRepository;
    private IMetadataManager metadataManager;
    private String allGroup = "1";
    private String stylePath;

    /**
     * Constructor.
     */
    public AIVStatusActions() {
    }

    /**
     * Initializes the StatusActions class with external info from GeoNetwork.
     *
     * @param context
     * @param dbms
     */
    public void init(ServiceContext context) throws Exception {

        this.context = context;
        this.metadataUtils = context.getBean(IMetadataUtils.class);
        this.language = context.getLanguage();

        this.sm = context.getBean(SettingManager.class);

        siteName = sm.getSiteName();
        host = sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_HOST);
        port = sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_PORT);
        from = sm.getValue(SYSTEM_FEEDBACK_EMAIL);
        username = sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_USERNAME);
        password = sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_PASSWORD);
        useSSL = Boolean.parseBoolean(sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_SSL));
        useTLS = Boolean.parseBoolean(sm.getValue(SYSTEM_FEEDBACK_MAILSERVER_TLS));

        if (host.length() == 0) {
            context.error("Mail server host not configured, email notifications won't be sent.");
            emailNotes = false;
        }

        if (port.length() == 0) {
            context.error("Mail server port not configured, email notifications won't be sent.");
            emailNotes = false;
        }

        if (from == null || from.length() == 0) {
            context.error("Mail feedback address not configured, email notifications won't be sent.");
            emailNotes = false;
        }

        session = context.getUserSession();
        replyTo = session.getEmailAddr();
        if (replyTo != null) {
            replyToDescr = session.getName() + " " + session.getSurname();
        } else {
            replyTo = from;
            replyToDescr = siteName;
        }

        dm = context.getBean(DataManager.class);
        metadataValidator = context.getBean(IMetadataValidator.class);
        metadataValidationRepository = context.getBean(MetadataValidationRepository.class);
        metadataStatusManager = context.getBean(IMetadataStatus.class);
        baseUrl = sm.getBaseURL();
        siteUrl = sm.getSiteURL(context);
        stylePath = context.getAppPath() + FS + Geonet.Path.STYLESHEETS + FS;
        metadataManager = context.getBean(IMetadataManager.class);
    }

    /**
     * Called when a metadata is created.
     *
     * @param id
     *            the id of the metadata
     */
/*
 	public void onCreate(int mid) throws Exception {
 		String changeMessage = "GeoNetwork gebruiker " + session.getUserId()
				+ " (" + session.getUsername()
				+ ") heeft metadata record met id " + mid + " gecrëeerd.";
        metadataStatusManager.setStatus(context, mid, Integer.valueOf(StatusValue.Status.JUSTCREATED), new ISODate(), changeMessage);
	}
*/

    /**
     * Called when a record is edited to set/reset status.
     *
     * @param mid       The metadata id that has been edited.
     * @param minorEdit If true then the edit was a minor edit.
     */
    public void onEdit(int mid, boolean minorEdit) throws Exception {
        if (Log.isTraceEnabled(Geonet.DATA_MANAGER)) {
            Log.trace(Geonet.DATA_MANAGER, "DefaultStatusActions.onEdit(" + mid
                + ", " + minorEdit + ") with status " + metadataStatusManager.getCurrentStatus(mid));
        }
        if (!minorEdit && !metadataStatusManager.getCurrentStatus(mid).equals(StatusValue.Status.DRAFT) &&
            (context.getBean(IMetadataManager.class) instanceof DraftMetadataManager)) {
            ResourceBundle messages = ResourceBundle.getBundle("org.fao.geonet.api.Messages", new Locale(this.language));
            String changeMessage = String.format(messages.getString("status_email_text"), session.getUserId(), session.getUsername(), mid);
            //unsetAllOperations(id);
            Log.trace(Geonet.DATA_MANAGER, "Set DRAFT to current record with id " + mid);
            metadataStatusManager.setStatus(context, mid, Integer.valueOf(StatusValue.Status.DRAFT), new ISODate(), changeMessage);
        }
    }
/*
	public void onCancelEdit(String id) throws Exception {
        String currentStatusId = metadataStatusManager.getCurrentStatus(Integer.parseInt(id));
		if (!(StatusValue.Status.APPROVED.equals(currentStatusId) || StatusValue.Status.RETIRED.equals(currentStatusId) || StatusValue.Status.RETIRED_FOR_AGIV.equals(currentStatusId) || StatusValue.Status.REJECTED_FOR_REMOVE.equals(currentStatusId))) {

			// String changeMessage =
			// "GeoNetwork user "+session.getUserId()+" ("+session.getUsername()+") canceled edit session for metadata record "+id;
			String changeMessage = "GeoNetwork gebruiker "
					+ session.getUserId() + " (" + session.getUsername()
					+ ") heeft de editeersessie van metadata record met id "
					+ id + " geannuleerd.";
			// unsetAllOperations(id);
			MetadataStatus statusToRevertTo = metadataStatusManager.getPreviousPublishedStatus(Integer.parseInt(id));
			if (statusToRevertTo==null) {
				IMetadataUtils metadataRepository = context.getBean(IMetadataUtils.class);
		        AbstractMetadata metadata = metadataRepository.findOne(id);
		        SearchManager searchManager = context.getBean(SearchManager.class);
	        	backupFile(metadata, context);
		        IO.deleteFileOrDirectory(Lib.resource.getMetadataDir(context.getBean(GeonetworkDataDirectory.class),
		                String.valueOf(metadata.getId())));
		        dm.deleteMetadata(context, metadata.getId() + "");
		        searchManager.forceIndexChanges();
			} else {
				statusToRevertTo.getId().setChangeDate(new ISODate());
				statusToRevertTo.setChangeMessage(changeMessage);
	            metadataStatusManager.setStatusExt(statusToRevertTo);
			}
		}
	}
*/

    /**
     * Called when a record status is added.
     *
     * @param listOfStatus
     * @return
     * @throws Exception
     */
    public Set<Integer> onStatusChange(List<MetadataStatus> listOfStatus) throws Exception {

        Set<Integer> unchanged = new HashSet<Integer>();

        // -- process the metadata records to set status
        for (MetadataStatus status : listOfStatus) {
            Map<String, String> recordsToBeDeleted = new HashMap<String, String>();
//			Map<String, Map<String,String>> changedMetadataIdsToInformOwner = new HashMap<String,Map<String,String>>();
            Map<String, Map<String, String>> changedMetadataIdsToInformEditors = new HashMap<String, Map<String, String>>();
            Map<String, Map<String, String>> changedMetadataIdsToInformReviewers = new HashMap<String, Map<String, String>>();
            Map<String, Map<String, String>> changedMetadataIdsToInformAdministrators = new HashMap<String, Map<String, String>>();
            String statusId = status.getId().getStatusId() + "";
            Set<Integer> listOfId = new HashSet<Integer>(1);
            listOfId.add(status.getId().getMetadataId());
            for (Integer mid : listOfId) {
                String currentStatusId = metadataStatusManager.getCurrentStatus(mid);
                if (context.isDebugEnabled()) {
                    context.debug("Starting statusChange to " + status.getId().getStatusId() + " for #"
                        + listOfId.size() + " metadata");
                }

                // --- For the workflow, if the status is already set to value
                // of status then do nothing. This does not apply to task and event.
                if (status.getStatusValue().getType().equals(StatusValueType.workflow) &&
                    (statusId).equals(currentStatusId)) {
                    if (context.isDebugEnabled()) {
                        context.debug(String.format("Metadata %s already has status %s ",
                            status.getId().getMetadataId(), status.getId().getStatusId()));
                    }
                    unchanged.add(status.getId().getMetadataId());
                    continue;
                }

                // --- Apply changes based on status change
                // TODO: Would be good to report what has been done ?
                IMetadataUtils metadataRepository = context.getBean(IMetadataUtils.class);
                AbstractMetadata metadata = metadataRepository.findOne(mid);
                Map<String, String> notificationProperties = new HashMap<String, String>();
                try {
                    applyRulesForStatusChange(status, metadata, currentStatusId, unchanged, notificationProperties);
                    if (!unchanged.contains(mid)) {

                        // --- inform content reviewers if the status is submitted
                        try {
                            getUserToNotify(statusId, metadata, currentStatusId, notificationProperties, recordsToBeDeleted, changedMetadataIdsToInformEditors, changedMetadataIdsToInformReviewers, changedMetadataIdsToInformAdministrators);
                            notify(status, changedMetadataIdsToInformEditors, changedMetadataIdsToInformReviewers, changedMetadataIdsToInformAdministrators);
                        } catch (Exception e) {
                            context.warning(String.format(
                                "Failed to send notification on status change for metadata %s with status %s. Error is: %s",
                                status.getId().getMetadataId(), status.getId().getStatusId(), e.getMessage()));
                        }

                        //Throw events
                        Log.trace(Geonet.DATA_MANAGER, "Throw workflow events.");
                        Log.debug(Geonet.DATA_MANAGER, "  > Status changed for record (" + mid + ") to status " + status);
                        context.getApplicationContext().publishEvent(new MetadataStatusChanged(
                            metadataUtils.findOne(Integer.valueOf(mid)),
                            status.getStatusValue(), status.getChangeMessage(),
                            status.getId().getUserId()));
                    }
                } catch (Throwable x) {
                    context.error("ERROR in statusChange " + x.getMessage());
                    x.printStackTrace();
                    throw new Exception(x);
                } finally {
                    try {
                        for (String idToBeDeleted : recordsToBeDeleted.keySet()) {
                            AbstractMetadata metadataToBeDeleted = metadataRepository.findOne(idToBeDeleted);
                            SearchManager searchManager = context.getBean(SearchManager.class);
                            backupFile(metadataToBeDeleted, context);
                            IO.deleteFileOrDirectory(Lib.resource.getMetadataDir(context.getBean(GeonetworkDataDirectory.class),
                                String.valueOf(idToBeDeleted)));
                            metadataManager.deleteMetadata(context, idToBeDeleted);
                            searchManager.forceIndexChanges();
                        }
                    } catch (Exception e) {
                        System.out.println("ERROR in statusChange during delete metadata " + e.getMessage());
                    }
                }
            }
        }

        return unchanged;
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
                changeAllowed = changeAllowedByEditor(currentStatusId, statusId, metadata, accessManager);
            }
        }
        return changeAllowed;
    }

    protected abstract boolean changeAllowedByAdmin(String currentStatusId, String statusId);
    protected abstract boolean changeAllowedByReviewer(String currentStatusId, String statusId);
    protected abstract boolean changeAllowedByEditor(String currentStatusId, String statusId, AbstractMetadata metadata, AccessManager accessManager) throws Exception;

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
    }

    /**
     * Collect the list of users to notify.
     *
     * @param statusId
     * @param metadata
     * @param currentStatusId
     * @param notificationProperties
     * @param recordsToBeDeleted
     * @param changedMetadataIdsToInformEditors
     * @param changedMetadataIdsToInformReviewers
     * @param changedMetadataIdsToInformAdministrators
     */
    protected void getUserToNotify(String statusId, AbstractMetadata metadata, String currentStatusId, Map<String, String> notificationProperties, Map<String, String> recordsToBeDeleted, Map<String, Map<String, String>> changedMetadataIdsToInformEditors, Map<String, Map<String, String>> changedMetadataIdsToInformReviewers, Map<String, Map<String, String>> changedMetadataIdsToInformAdministrators) throws Exception {
    }

    /**
     * Send email to a list of users. The list of users is defined based on
     * the notification level of the status. See {@link StatusValueNotificationLevel}.
     *
     * @param status
     * @param changedMetadataIdsToInformEditors
     * @param changedMetadataIdsToInformReviewers
     * @param changedMetadataIdsToInformAdministrators
     * @throws Exception
     */
    private void notify(MetadataStatus status, Map<String, Map<String, String>> changedMetadataIdsToInformEditors, Map<String, Map<String, String>> changedMetadataIdsToInformReviewers, Map<String, Map<String, String>> changedMetadataIdsToInformAdministrators) throws Exception {
        String statusId = status.getId().getStatusId() + "";
        String statusDescription = status.getStatusValue().getLabelTranslations().containsKey(context.getLanguage()) ?
            status.getStatusValue().getLabelTranslations().get(context.getLanguage()) :
            status.getStatusValue().getLabelTranslations().get("eng");
        String changeMessage = status.getChangeMessage();
        String changeDate = status.getId().getChangeDate().toString();
        List<String> emailMetadataIdList = new ArrayList<String>();
        if (changedMetadataIdsToInformAdministrators.size() > 0) {
            informContentUsers(changedMetadataIdsToInformAdministrators, changeDate,
                changeMessage, Profile.Administrator, statusId, statusDescription, emailMetadataIdList);
        }
        if (changedMetadataIdsToInformReviewers.size() > 0) {
            informContentUsers(changedMetadataIdsToInformReviewers, changeDate,
                changeMessage, Profile.Reviewer, statusId, statusDescription, emailMetadataIdList);
        }
        if (changedMetadataIdsToInformEditors.size() > 0) {
            informContentUsers(changedMetadataIdsToInformEditors, changeDate,
                changeMessage, Profile.Editor, statusId, statusDescription, emailMetadataIdList);
        }
    }

    /**
     * Check the validity of a record against XSD and mandatory schematrons
     *
     * @param metadata Metadata to be validated
     * @return true if the record is valid
     * @throws Exception
     */
    protected boolean statusChangeAllowed(AbstractMetadata metadata) throws Exception {

        // AGIV: trigger validation when status is changed. If one of the
        // validations fails, the change is not allowed (depending on which
        // logical node this is).
        //
        // heikki: use non-boolean doValidate, to get errorreport in session (we
        // need to know which validation failed exactly)
        // OR use the other doValidate and then here retrieve validationresult
        // from db <-- better because errorreport is too detailed, we want the
        // summary here

        // the workspace md should be validated if the current status is draft
        // or rejected and the status to be set is submitted; OR
        // if the current status is submitted and the status to be set is
        // approved


        // if the md is not valid, analyze why not and allow or disallow status
        // change depending on what exactly was not valid and which logical node
        // this is

        boolean valid = metadataValidator.doValidate(metadata, context.getLanguage());
        if (!valid) {
            // retrieve validationreport from db
            // this is a list of <MetadataValidation> with <valtype>, <status>,
            // <tested>, and <failed> attribute
            List<MetadataValidation> validationInfos = metadataValidationRepository
                .findAllById_MetadataId(metadata.getId());

            // if this is AGIV Edit or the AGIV View Node:
            // Only when the metadata validates against the ISO schemas and
            // schematrons, it can be set to
            // "Submitted to AGIV",
            // "Submitted to the Principal Editor", and
            // "Approved by AGIV" states.
            // In case these validations do not succeed, the metadata is
            // returned to the "Draft" state and the
            // user informed.
            // Even if a metadata record does not validate against the INSPIRE
            // and GDI-Vlaanderen Best Practices
            // schematrons, it can be set to the above mentioned states (these
            // both checks are not blocking).

            // GDI Vlaanderen Node:
            // Only be set to "Submitted" or "Approved" when the metadata
            // validates against the ISO schemas and
            // schematrons. If a metadata record's status is changed, the
            // metadata validation (all measures)
            // will be triggered. Metadata records only get the "Approved" or
            // "Submitted" status if the ISO XSD
            // and schematron validation was performed OK.
            // INSPIRE and GDI-Vlaanderen Best Practices validity are given for
            // information only, metadata can
            // be saved and set to the above mentioned states even in case that
            // the validation for these 2
            // measures was not successful.

            // INSPIRE Node:
            // only gets its metadata through Harvesting. INSPIRE compliance is
            // enforced by the validation in
            // the CSW INSPIRE harvester.

            // heikki: so in short, the status change is only allowed if ISO XSD
            // and schematron validation has
            // passed; the same for all logical nodes !

            for (MetadataValidation validationInfo : validationInfos) {
                // check that xsd validation succeeded
                if (validationInfo.getId().getValidationType().equals("xsd")) {
                    if (validationInfo.getStatus() != MetadataValidationStatus.VALID) {
                        context.info("Metadata with id " + metadata.getId()
                            + " failed XSD validation: status change not allowed");
                        return false;
                    }
                } else {
                    // check if the record is valid on mandatory schematron
                    if (isMandatorySchematron(validationInfo.getId().getValidationType())) {
                        if (validationInfo.getStatus() != MetadataValidationStatus.VALID) {
                            context.info("Metadata with id " + metadata.getId()
                                + " failed ISO Schematron and/or geonetwork Schematron validation: status change not allowed");
                            return false;
                        }
                    }
                }
            }
        }
        return true;
    }

    /**
     * Check if the validation report comes from a mandatory schematron {@link SchematronRequirement}
     *
     * @param valType type of the validation
     * @return true if schematron is mandatory
     */
    private boolean isMandatorySchematron(String valType) {
        //TODO Check criteria from the Database instead of hard coded
        return
            valType.equals("schematron-rules-iso") ||
                valType.equals("schematron-rules-geonetwork");
    }

    // -------------------------------------------------------------------------
    // Private methods
    // -------------------------------------------------------------------------

    /**
     * Set all operations on 'All' Group. Used when status changes from
     * submitted to approved.
     *
     * @param mdId The metadata id to set privileges on
     */
    protected void setAllOperations(String mdId) throws Exception {
        String allGroup = "1";
        dm.setOperation(context, mdId, allGroup, ReservedOperation.view);
        dm.setOperation(context, mdId, allGroup, ReservedOperation.download);
        //dm.setOperation(context, mdId, groupId, ReservedOperation.editing);
        dm.setOperation(context, mdId, allGroup, ReservedOperation.notify);
        dm.setOperation(context, mdId, allGroup, ReservedOperation.dynamic);
        dm.setOperation(context, mdId, allGroup, ReservedOperation.featured);
    }

    /**
     * Set all operations on 'All' Group. Used when status changes from
     * submitted to approved.
     *
     * @param mdId The metadata id to set privileges on
     */
    private void setAllOperationsForUserGroup(String mdId) throws Exception {
        UserGroupRepository userGroupRepository = context.getBean(UserGroupRepository.class);
        List<Integer> groups = userGroupRepository.findGroupIds(hasUserId(Integer.valueOf(session.getUserId())));
        for (Iterator<Integer> i = groups.iterator(); i.hasNext(); ) {
            int groupId = i.next().intValue();
            if (!(groupId == -1 || groupId == 0 || groupId == 1)) {
                dm.setOperation(context, mdId, String.valueOf(groupId), ReservedOperation.view);
                dm.setOperation(context, mdId, String.valueOf(groupId), ReservedOperation.download);
                //dm.setOperation(context, mdId, String.valueOf(groupId), ReservedOperation.editing);
                dm.setOperation(context, mdId, String.valueOf(groupId), ReservedOperation.notify);
                dm.setOperation(context, mdId, String.valueOf(groupId), ReservedOperation.dynamic);
                dm.setOperation(context, mdId, String.valueOf(groupId), ReservedOperation.featured);
            }
        }
    }

    /**
     * Unset all operations on 'All' Group. Used when status changes from approved to something
     * else.
     *
     * @param mdId The metadata id to unset privileges on
     */
    protected void unsetAllOperations(int mdId) throws Exception {
        Log.trace(Geonet.DATA_MANAGER, "AIVStatusActions.unsetAllOperations(" + mdId + ")");

        int allGroup = 1;
        for (ReservedOperation op : ReservedOperation.values()) {
            dm.forceUnsetOperation(context, mdId, allGroup, op.getId());
        }
    }

    /**
     * Inform content users of metadata records in list
     *
     * @param metadataMap         The selected set of metadata records
     * @param changeDate          The date that of the change in status
     * @param changeMessage       Message supplied by the user that set the status
     * @param profile             Profile of users to be informed
     * @param statusId            New status
     * @param emailMetadataIdList List for adding email adresses to sent to the metadata info
     */
    private void informContentUsers(Map<String, Map<String, String>> metadataMap,
                                    String changeDate, String changeMessage, Profile profile, String statusId, String statusDescription, List<String> emailMetadataIdList) throws Exception {

        UserRepository userRepository = context.getBean(UserRepository.class);
        // --- get content reviewers (sorted on content reviewer userid)
        List<Object[]> contentUsers;
        if (profile.equals(Profile.Administrator)) {
            contentUsers = userRepository.getContentAdmins(metadataMap.keySet());
        } else {
            contentUsers = userRepository.getContentUsers(metadataMap.keySet(), profile.ordinal());
        }

        String subject = "Status metadata record(s) gewijzigd naar '" + statusDescription + "' door " + replyTo + " ("
            + replyToDescr + ") op " + changeDate;

        processList(context, replyTo, replyToDescr, contentUsers, subject, statusId, changeDate, changeMessage, metadataMap, emailMetadataIdList);
    }

    protected void processList(ServiceContext context, String replyTo, String replyToDescr, List<Object[]> contentUsers, String subject, String statusId,
                               String changeDate, String changeMessage, Map<String, Map<String, String>> metadataMap, List<String> emailMetadataIdList)
        throws Exception {
    }

    public static void backupFile(AbstractMetadata metadata, ServiceContext context) {
        Log.trace(Geonet.DATA_MANAGER, "Backing up record " + metadata.getId());
        Path outDir = Lib.resource.getRemovedDir(metadata.getId());
        Path outFile;
        try {
            // When metadata records contains character not supported by filesystem
            // it may be an issue. eg. acri-st.fr/96443
            outFile = outDir.resolve(URLEncoder.encode(metadata.getUuid(), Constants.ENCODING) + ".zip");
        } catch (UnsupportedEncodingException e1) {
            outFile = outDir.resolve(String.format(
                "backup-%s-%s.mef",
                new Date(), metadata.getUuid()));
        }

        Path file = null;
        try {
            file = MEFLib.doExport(context, metadata.getUuid(), "full", false, true, false, false, true);
            Files.createDirectories(outDir);
            try (InputStream is = IO.newInputStream(file);
                 OutputStream os = Files.newOutputStream(outFile)) {
                BinaryFile.copy(is, os);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (file == null) {
                IO.deleteFile(file, false, Geonet.MEF);
            }
        }
    }

    /**
     * Process the users and metadata records for emailing notices.
     *
     * @param context      The service context
     * @param dbms         The dbms
     * @param replyTo      The replyTo email
     * @param replyToDescr The replyTo description configured in the web.xml
     * @param records      The selected set of records
     * @param subject      Subject to be used for email notices
     * @param status       The status being set
     * @param changeDate   Datestamp of status change
     */
    @SuppressWarnings("unchecked")
    protected void processList(ServiceContext context, String replyTo, String replyToDescr, List<Object[]> contentUsers, String subject, String status,
                               String changeDate, String changeMessage, Map<String, Map<String, String>> metadataMap, List<String> emailMetadataIdList, String nodeType)
        throws Exception {
        Set<String> metadataIds = new HashSet<String>();
        String currentUserId = null;
        String userId = null;
        String currentEmail = null;
        Iterator<Object[]> recordsIterator = contentUsers.iterator();
        Element root = null;
        Element metadata = null;
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
                root = getNewRootElement(context, status, changeMessage, nodeType);
            } else if (!currentUserId.equals(userId)) {
                if (StringUtils.isNotBlank(currentEmail) && metadataIds.size() > 0) {
                    sendEmail(context, currentEmail, root);
                    metadataIds.clear();
                }
                currentUserId = userId;
                currentEmail = String.valueOf(record[5]);
                if (currentEmail != null) {
                    currentEmail = currentEmail.toLowerCase();
                }
                root = getNewRootElement(context, status, changeMessage, nodeType);
            }
            if (StringUtils.isNotBlank(currentEmail) && !emailMetadataIdList.contains(currentEmail + "_" + metadataId)) {
                emailMetadataIdList.add(currentEmail + "_" + metadataId);
                metadataIds.add(metadataId);
                metadata = new Element("metadata");
                root.addContent(metadata);
                metadata.addContent(new Element("url").setText(siteUrl + "catalog.search#/metadata/" + metadataUUID));
                metadata.addContent(new Element("title").setText(metadataMap.get(metadataUUID).get("title").toString()));
                metadata.addContent(new Element("currentStatus").setText(metadataMap.get(metadataUUID).get("currentStatus").toString()));
                if (metadataMap.get(metadataUUID).get("previousStatus") != null) {
                    metadata.addContent(new Element("previousStatus").setText(metadataMap.get(metadataUUID).get("previousStatus").toString()));
                }
            }
        }

        if (StringUtils.isNotBlank(currentEmail) && metadataIds.size() > 0) {
            sendEmail(context, currentEmail, root);
        }
    }

    public Element getNewRootElement(ServiceContext context, String status, String changeMessage, String nodeType) {
        Element user = new Element("user");
        user.addContent(new Element("surname").setText(context.getUserSession().getSurname()));
        user.addContent(new Element("name").setText(context.getUserSession().getName()));
        Element group = new Element("group");
        group.addContent(new Element("description").setText(context.getUserSession().getOrganisation()));
        Element root = new Element("root");
        root.addContent(user);
        root.addContent(group);
        root.addContent(new Element("node").setText(nodeType));
        root.addContent(new Element("baseUrl").setText(baseUrl));
        root.addContent(new Element("siteUrl").setText(siteUrl));
        root.addContent(new Element("metadatacenter").setText(siteName));
        root.addContent(new Element("status").setText(status));
        root.addContent(new Element("changeMessage").setText(changeMessage));
        return root;
    }

    public void sendEmail(ServiceContext context, String sendTo, Element params)
        throws Exception {
        if (!emailNotes) {
            context.info("Would send email with message grablock service but no email server configured");
        } else {
            String styleSheet = context.getAppPath() + FS + Geonet.Path.STYLESHEETS + FS + Geonet.File.STATUS_CHANGE_EMAIL;
            Element emailElement = Xml.transform(params, IO.toPath(styleSheet));
            MailSender sender = new MailSender(context);
            sender.sendWithReplyTo(host, Integer.parseInt(port), username, password, useSSL, useTLS, true, from, siteName, sendTo, null, replyTo, siteName, emailElement.getChildText("subject"),
                emailElement.getChildText("message"));
        }
    }

}
