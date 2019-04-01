package org.fao.geonet.kernel.metadata;

import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import org.fao.geonet.ApplicationContextHolder;
import org.fao.geonet.Logger;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.*;
import org.fao.geonet.kernel.AccessManager;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.datamanager.IMetadataStatus;
import org.fao.geonet.kernel.datamanager.IMetadataUtils;
import org.fao.geonet.kernel.datamanager.IMetadataValidator;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.kernel.setting.Settings;
import org.fao.geonet.repository.*;
import org.fao.geonet.util.MailUtil;
import org.springframework.context.ApplicationContext;

import java.io.File;
import java.text.MessageFormat;
import java.util.*;

@SuppressWarnings("Duplicates")
public class AgivStatusActions extends DefaultStatusActions implements StatusActions {

    private String fromDescr, replyTo, replyToDescr;
    private ServiceContext context;
    private AccessManager am;
    private DataManager dm;
    private String siteUrl;
    private UserSession session;
    private boolean emailNotes = true;
    private String stylePath;
    private static String FS = File.separator;

    private IMetadataUtils metadataUtils;
    private IMetadataValidator metadataValidator;
    private MetadataValidationRepository metadataValidationRepository;
    private IMetadataStatus metadataStatusManager;
    private Logger logger;

    private static final String nodeType = "general";

    @Override
    public void init(ServiceContext context) throws Exception {
        this.context = context;

        SettingManager sm = context.getBean(SettingManager.class);
        am = context.getBean(AccessManager.class);

        String host = sm.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_HOST);
        String port = sm.getValue(Settings.SYSTEM_FEEDBACK_MAILSERVER_PORT);
        String from = sm.getValue(Settings.SYSTEM_FEEDBACK_EMAIL);
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

        fromDescr = sm.getValue("metadata/workflow");

        session = context.getUserSession();
        replyTo = session.getEmailAddr();
        if (replyTo != null) {
            replyToDescr = session.getName() + " " + session.getSurname();
        } else {
            replyTo = from;
            replyToDescr = fromDescr;
        }

        dm = context.getBean(DataManager.class);
        siteUrl = sm.getSiteURL(context);
        stylePath = context.getAppPath() + FS + Geonet.Path.STYLESHEETS + FS;
        metadataUtils = context.getBean(IMetadataUtils.class);
        metadataValidator = context.getBean(IMetadataValidator.class);
        metadataValidationRepository = context.getBean(MetadataValidationRepository.class);
        metadataStatusManager = context.getBean(IMetadataStatus.class);
        logger = context.getLogger();
    }

    @Override
    public void onEdit(int id, boolean minorEdit) throws Exception {

        // When a edition start on a record, the status is automatically set to DRAFT
        // But is not un-published
        if (!minorEdit && !dm.getCurrentStatus(id).equals(StatusValue.Status.DRAFT)) {
            String changeMessage = "GeoNetwork gebruiker "
                + session.getUserId() + " (" + session.getUsername()
                + ") heeft metadata record met id " + id + " bewerkt.";
            dm.setStatus(context, id, new Integer(StatusValue.Status.DRAFT), new ISODate(), changeMessage);
        }
    }

    @Override
    public Set<Integer> onStatusChange(List<MetadataStatus> statusList) throws Exception {
        logger.info("Starting status change for #" + statusList.size() + " records");

        Set<Integer> recordsToDelete = new HashSet<>();
        Set<Integer> unchanged = new HashSet<>();
        try {
            for (MetadataStatus status : statusList) {
                int mdId = status.getId().getMetadataId();
                String currentStatusId = dm.getCurrentStatus(mdId);
                String statusId = String.valueOf(status.getId().getStatusId());

                // If the status value does not change then do nothing
                if (status.getStatusValue().getType().equals(StatusValueType.workflow) && (statusId).equals(currentStatusId)) {
                    if (context.isDebugEnabled()) {
                        context.debug(String.format("Metadata %s already has status %s ", status.getId().getMetadataId(), status.getId().getStatusId()));
                    }
                    unchanged.add(status.getId().getMetadataId());
                    continue;
                }

                AbstractMetadata metadata = metadataUtils.findOne(mdId);
                MetadataDataInfo dataInfo = metadata.getDataInfo();
                boolean isTemplate = dataInfo.getType() == MetadataType.TEMPLATE;

                // Change the status of a metadata.
                // In order to set the status to SUBMITTED_FOR_AGIV, APPROVED_BY_AGIV or APPROVED,
                // the record must be valid
                // This rule does not apply for template
                if (statusChangeAllowedByUser(currentStatusId, statusId, String.valueOf(mdId)) && (
                    isTemplate ||
                        !(statusId.equals(StatusValue.Status.SUBMITTED_FOR_AGIV) ||
                            statusId.equals(StatusValue.Status.APPROVED_BY_AGIV) ||
                            statusId.equals(StatusValue.Status.APPROVED)) ||
                        statusChangeAllowed(metadata))) {

                    logger.info("Change status of metadata with uuid " + metadata.getUuid()
                        + " from " + currentStatusId + " to " + statusId);

                    if (statusId.equals(StatusValue.Status.APPROVED)) {
                        metadataStatusManager.setStatusExt(status);
                        setAllOperations(String.valueOf(metadata.getId()));

                    } else if (statusId.equals(StatusValue.Status.RETIRED)) {
                        metadataStatusManager.setStatusExt(status);
                        unsetAllOperations(metadata.getId());

                    } else if (statusId.equals(StatusValue.Status.REJECTED_FOR_RETIRE) || statusId.equals(StatusValue.Status.REJECTED_FOR_REMOVE)) {
                        // set status, indexing is assumed to take place later
                        metadataStatusManager.setStatusExt(getPreviousStatus(metadata.getId()));
                    } else {
                        metadataStatusManager.setStatusExt(status);
                    }

                    // When a status is updated, get all the users profile who need to be notified
                    Set<Profile> profilesToBeNotified = getProfileToNotify(status, currentStatusId);
                    if (statusId.equals(StatusValue.Status.REMOVED)) {
                        recordsToDelete.add(metadata.getId());
                    }
                    List<User> usersToNotify = getUserToNotify(status, profilesToBeNotified);
                    notify(usersToNotify, status);


                } else {
                    unchanged.add(metadata.getId());
                    logger.info("Status change not allowed for metadata with uuid "
                        + metadata.getUuid() + " from " + currentStatusId + " to " + status);
                }
            }
        } catch (Exception e) {
            logger.error("ERROR in statusChange " + e.getMessage());
            e.printStackTrace();
            throw new Exception(e);
        } finally {
            try {
                for (int id : recordsToDelete) {
                    dm.deleteMetadata(context, String.valueOf(id));
                }
            } catch (Exception e) {
                logger.error("ERROR in statusChange during delete metadata " + e.getMessage());
                e.printStackTrace();
            }
        }
        return unchanged;
    }


    /**
     * Check if the status change is allowed. Since the same check is made in the view,
     * this function should always return true but is still there for security reason.
     * @param currentStatus The status before change
     * @param status        The status to be set
     * @param mdId          The metadata identifier
     * @return true if the status can be changed
     * @throws Exception
     */
    private boolean statusChangeAllowedByUser(String currentStatus, String status, String mdId) throws Exception {
        boolean changeAllowed = am.canEdit(context, mdId);
        if (changeAllowed) {
            if (session.getProfile().equals(Profile.Administrator)) {
                switch (status) {
                    case StatusValue.Status.UNKNOWN: 
                    case StatusValue.Status.JUSTCREATED: 
                        break;
                    case StatusValue.Status.DRAFT: 
                    case StatusValue.Status.SUBMITTED: 
                    case StatusValue.Status.REJECTED: 
                        changeAllowed = false;
                        break;
                    case StatusValue.Status.APPROVED: 
                        if (currentStatus.equals(StatusValue.Status.SUBMITTED) || currentStatus.equals(StatusValue.Status.REJECTED) || currentStatus.equals(StatusValue.Status.REJECTED_BY_AGIV) || currentStatus.equals(StatusValue.Status.RETIRED_FOR_AGIV) || currentStatus.equals(StatusValue.Status.REMOVED_FOR_AGIV) || currentStatus.equals(StatusValue.Status.REJECTED_FOR_RETIRE) || currentStatus.equals(StatusValue.Status.REJECTED_FOR_REMOVE)) {
                            changeAllowed = false;
                        }
                        break;
                    case StatusValue.Status.RETIRED: 
                        if (nodeType.equalsIgnoreCase("agiv") && !currentStatus.equals(StatusValue.Status.RETIRED_FOR_AGIV)) {
                            changeAllowed = false;
                        }
                        break;
                    case StatusValue.Status.SUBMITTED_FOR_AGIV: 
                        if (!currentStatus.equals(StatusValue.Status.DRAFT)) {
                            changeAllowed = false;
                        }
                        break;
                    case StatusValue.Status.APPROVED_BY_AGIV: 
                        if (!currentStatus.equals(StatusValue.Status.DRAFT) && !currentStatus.equals(StatusValue.Status.SUBMITTED_FOR_AGIV)) {
                            changeAllowed = false;
                        }
                        break;
                    case StatusValue.Status.REJECTED_BY_AGIV: 
                        if (currentStatus.equals(StatusValue.Status.DRAFT) || currentStatus.equals(StatusValue.Status.APPROVED) || currentStatus.equals(StatusValue.Status.RETIRED) || currentStatus.equals(StatusValue.Status.SUBMITTED) || currentStatus.equals(StatusValue.Status.REJECTED) ||
                            currentStatus.equals(StatusValue.Status.APPROVED_BY_AGIV) || currentStatus.equals(StatusValue.Status.RETIRED_FOR_AGIV) || currentStatus.equals(StatusValue.Status.REMOVED_FOR_AGIV)) {
                            changeAllowed = false;
                        }
                        break;
                    case StatusValue.Status.RETIRED_FOR_AGIV: 
                        if (!currentStatus.equals(StatusValue.Status.APPROVED)) {
                            changeAllowed = false;
                        }
                        break;
                    case StatusValue.Status.REMOVED_FOR_AGIV: 
                        if (currentStatus.equals(StatusValue.Status.SUBMITTED_FOR_AGIV) || currentStatus.equals(StatusValue.Status.APPROVED_BY_AGIV) || currentStatus.equals(StatusValue.Status.RETIRED_FOR_AGIV)) {
                            changeAllowed = false;
                        }
                        break;
                    case StatusValue.Status.REMOVED: 
                        if (nodeType.equalsIgnoreCase("agiv") && !currentStatus.equals(StatusValue.Status.REMOVED_FOR_AGIV)) {
                            changeAllowed = false;
                        }
                        break;
                    case StatusValue.Status.REJECTED_FOR_RETIRE: 
                        if (!currentStatus.equals(StatusValue.Status.RETIRED_FOR_AGIV)) {
                            changeAllowed = false;
                        }
                        break;
                    case StatusValue.Status.REJECTED_FOR_REMOVE: 
                        if (!currentStatus.equals(StatusValue.Status.REMOVED_FOR_AGIV)) {
                            changeAllowed = false;
                        }
                        break;
                    default:
                        break;
                }

            } else if (session.getProfile().equals(Profile.Reviewer)) {
                if (currentStatus.equals(StatusValue.Status.SUBMITTED_FOR_AGIV) || currentStatus.equals(StatusValue.Status.APPROVED_BY_AGIV) || currentStatus.equals(StatusValue.Status.RETIRED_FOR_AGIV) || currentStatus.equals(StatusValue.Status.REMOVED_FOR_AGIV)) {
                    changeAllowed = false;
                } else {
                    switch (status) {
                        case StatusValue.Status.UNKNOWN: 
                        case StatusValue.Status.DRAFT: 
                        case StatusValue.Status.JUSTCREATED: 
                        case StatusValue.Status.APPROVED_BY_AGIV: 
                        case StatusValue.Status.REJECTED_BY_AGIV: 
                        case StatusValue.Status.REMOVED: 
                        case StatusValue.Status.REJECTED_FOR_RETIRE: 
                        case StatusValue.Status.REJECTED_FOR_REMOVE: 
                            changeAllowed = false;
                            break;
                        case StatusValue.Status.APPROVED: 
                            if (nodeType.equalsIgnoreCase("agiv")) {
                                changeAllowed = false;
                            }
                            break;
                        case StatusValue.Status.RETIRED: 
                            if (nodeType.equalsIgnoreCase("agiv") || !currentStatus.equals(StatusValue.Status.APPROVED)) {
                                changeAllowed = false;
                            }
                            break;
                        case StatusValue.Status.SUBMITTED: 
                        case StatusValue.Status.SUBMITTED_FOR_AGIV: 
                            if (currentStatus.equals(StatusValue.Status.APPROVED) || currentStatus.equals(StatusValue.Status.RETIRED)) {
                                changeAllowed = false;
                            }
                            break;
                        case StatusValue.Status.REJECTED: 
                            if (currentStatus.equals(StatusValue.Status.APPROVED) || currentStatus.equals(StatusValue.Status.RETIRED) || currentStatus.equals(StatusValue.Status.REJECTED_BY_AGIV)) {
                                changeAllowed = false;
                            }
                            break;
                        case StatusValue.Status.RETIRED_FOR_AGIV: 
                            if (currentStatus.equals(StatusValue.Status.RETIRED) || currentStatus.equals(StatusValue.Status.REMOVED_FOR_AGIV)) {
                                changeAllowed = false;
                            }
                            break;
                        case StatusValue.Status.REMOVED_FOR_AGIV: 
                            if (currentStatus.equals(StatusValue.Status.RETIRED_FOR_AGIV)) {
                                changeAllowed = false;
                            }
                            break;
                        default:
                            break;
                    }
                }
            } else if (session.getProfile().equals(Profile.Editor)) {
                if (!am.isOwner(context, mdId) || currentStatus.equals(StatusValue.Status.SUBMITTED) || currentStatus.equals(StatusValue.Status.SUBMITTED_FOR_AGIV)) {
                    changeAllowed = false;
                } else {
                    switch (status) {
                        case StatusValue.Status.UNKNOWN:
                        case StatusValue.Status.DRAFT:
                        case StatusValue.Status.APPROVED:
                        case StatusValue.Status.RETIRED:
                        case StatusValue.Status.REJECTED:
                        case StatusValue.Status.JUSTCREATED:
                        case StatusValue.Status.SUBMITTED_FOR_AGIV:
                        case StatusValue.Status.APPROVED_BY_AGIV:
                        case StatusValue.Status.REJECTED_BY_AGIV:
                        case StatusValue.Status.RETIRED_FOR_AGIV:
                        case StatusValue.Status.REMOVED_FOR_AGIV:
                        case StatusValue.Status.REMOVED:
                        case StatusValue.Status.REJECTED_FOR_RETIRE:
                        case StatusValue.Status.REJECTED_FOR_REMOVE:
                            changeAllowed = false;
                            break;
                        case StatusValue.Status.SUBMITTED:
                            if (!(currentStatus.equals(StatusValue.Status.DRAFT) || currentStatus.equals(StatusValue.Status.REJECTED) || currentStatus.equals(StatusValue.Status.REJECTED_BY_AGIV))) {
                                changeAllowed = false;
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        System.out.println(changeAllowed);
        return changeAllowed;
    }

    /**
     * Check the validity of a record against XSD and mandatory schematrons
     *
     * @param metadata Metadata to be validated
     * @return true if the record is valid
     * @throws Exception
     */
    private boolean statusChangeAllowed(AbstractMetadata metadata) throws Exception {

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
                        logger.info("Metadata with id " + metadata.getId()
                            + " failed XSD validation: status change not allowed");
                        return false;
                    }
                } else {
                    // check if the record is valid on mandatory schematron
                    if (isMandatorySchematron(validationInfo.getId().getValidationType())) {
                        if (validationInfo.getStatus() != MetadataValidationStatus.VALID) {
                            logger.info("Metadata with id " + metadata.getId()
                                + " failed ISO Schematron and/of geonetwork Schematron validation: status change not allowed");
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


    /**
     * Set all operations on 'All' Group. Used when status changes from
     * submitted to approved.
     *
     * @param mdId The metadata id to set privileges on
     */
    private void setAllOperations(String mdId) throws Exception {
        String allGroup = "1";
        for (ReservedOperation op : ReservedOperation.values()) {
            dm.setOperation(context, mdId, allGroup, String.valueOf(op.getId()));
        }
    }


    /**
     * Unset all operations on 'All' Group. Used when status changes from approved to something
     * else.
     *
     * @param mdId The metadata id to unset privileges on
     */
    private void unsetAllOperations(int mdId) throws Exception {
        int allGroup = 1;
        for (ReservedOperation op : ReservedOperation.values()) {
            dm.forceUnsetOperation(context, mdId, allGroup, op.getId());
        }
    }


    /**
     * Get the previous status to the current one
     *
     * @param mdId ID of the metadata
     * @return Previous status {@link MetadataStatus}
     * @throws Exception
     */
    private MetadataStatus getPreviousStatus(int mdId) throws Exception {
        List<MetadataStatus> statusList = metadataStatusManager.getAllStatus(mdId);
        //if current status is the first one
        if (statusList.size() <= 1) {
            return null;
        } else {
            return statusList.get(1);
        }
    }


    private List<User> getUserToNotify(MetadataStatus status, Set<Profile> profilesToBeNotified) {
        UserRepository userRepository = context.getBean(UserRepository.class);
        List<User> users = new ArrayList<>();

        // TODO: Status does not provide batch update
        // So taking care of one record at a time.
        // Currently the code could notify a mix of reviewers
        // if records are not in the same groups. To be improved.
        Set<Integer> listOfId = new HashSet<>(1);
        listOfId.add(status.getId().getMetadataId());

        List<Pair<Integer, User>> results = userRepository.findAllByGroupOwnerNameAndProfiles(
            listOfId,
            profilesToBeNotified,
            SortUtils.createSort(User_.name));

        for (Pair<Integer, User> p : results) {
            users.add(p.two());
        }

        return users;
    }


    private Set<Profile> getProfileToNotify(MetadataStatus status, String currentStatusId) {
        Set<Profile> profilesToBeNotified = new HashSet<>();
        switch (String.valueOf(status.getId().getStatusId())) {
            case StatusValue.Status.UNKNOWN: //UNKNOWN
                break;

            case StatusValue.Status.DRAFT:
                profilesToBeNotified.add(Profile.Editor);
                break;

            case StatusValue.Status.APPROVED:
            case StatusValue.Status.SUBMITTED_FOR_AGIV:
            case StatusValue.Status.REJECTED_BY_AGIV:
            case StatusValue.Status.RETIRED_FOR_AGIV:
            case StatusValue.Status.REMOVED_FOR_AGIV:
            case StatusValue.Status.REJECTED_FOR_RETIRE:
            case StatusValue.Status.REJECTED_FOR_REMOVE:
                profilesToBeNotified.add(Profile.Editor);
                profilesToBeNotified.add(Profile.Reviewer);
                profilesToBeNotified.add(Profile.Administrator);
                break;

            case StatusValue.Status.RETIRED:
            case StatusValue.Status.REMOVED:
                profilesToBeNotified.add(Profile.Editor);
                profilesToBeNotified.add(Profile.Reviewer);
                if (nodeType.equalsIgnoreCase("agiv")) {
                    profilesToBeNotified.add(Profile.Administrator);
                }
                break;

            case StatusValue.Status.SUBMITTED:
            case StatusValue.Status.REJECTED:
                profilesToBeNotified.add(Profile.Editor);
                profilesToBeNotified.add(Profile.Reviewer);
                break;

            case StatusValue.Status.JUSTCREATED:
                break;

            case StatusValue.Status.APPROVED_BY_AGIV:
                if (session.getProfile().equals(Profile.Administrator) && currentStatusId.equals(StatusValue.Status.DRAFT)) {
                    profilesToBeNotified.add(Profile.Editor);
                    profilesToBeNotified.add(Profile.Reviewer);
                }
                profilesToBeNotified.add(Profile.Administrator);
                break;

            default:
                break;
        }
        return profilesToBeNotified;
    }

    private void notify(List<User> usersToNotify, MetadataStatus status) throws Exception {
        ResourceBundle messages = ResourceBundle.getBundle("org.fao.geonet.api.Messages", new Locale(context.getLanguage()));

        String statusDescription = status.getStatusValue().getLabelTranslations().containsKey(context.getLanguage()) ?
            status.getStatusValue().getLabelTranslations().get(context.getLanguage()) :
            status.getStatusValue().getLabelTranslations().get("eng");

        String subjectTemplate = "";
        String messageTemplate = "";
        try {
            subjectTemplate = messages.getString("status_change_agiv_email_subject");
            messageTemplate = messages.getString("status_change_agiv_email_text");
        } catch (MissingResourceException e) {
            throw new Exception(e);
        }

        UserRepository userRepository = context.getBean(UserRepository.class);
        User owner = userRepository.findOne(status.getOwner());

        String subject = MessageFormat.format(subjectTemplate,
            statusDescription,
            replyTo,
            replyToDescr,
            status.getDueDate());

        String message = MessageFormat.format(messageTemplate,
            replyToDescr, // Author of the change
            status.getChangeMessage(),
            statusDescription,
            status.getId().getChangeDate(),
            status.getDueDate(),
            status.getCloseDate(),
            owner == null ? "" : owner.getName() + " " + owner.getSurname(),
            siteUrl);

        MetadataRepository metadataRepository = ApplicationContextHolder.get().getBean(MetadataRepository.class);
        Metadata metadata = metadataRepository.findOne(status.getId().getMetadataId());

        subject = DefaultStatusActions.compileMessageWithIndexFields(subject, metadata.getUuid(), context.getLanguage());
        message = DefaultStatusActions.compileMessageWithIndexFields(message, metadata.getUuid(), context.getLanguage());
        for (User user : usersToNotify) {
            sendEmail(user.getEmail(), subject, message);
        }
    }

    /**
     * Send the email message about change of status on a group of metadata records.
     *
     * @param sendTo        The recipient email address
     * @param subject       Subject to be used for email notices
     * @param message       Text of the mail
     */
    @Override
    protected void sendEmail(String sendTo, String subject, String message) throws Exception {

        if (!emailNotes) {
            context.info("Would send email \nTo: " + sendTo + "\nSubject: " + subject + "\n Message:\n" + message);
        } else {
            ApplicationContext applicationContext = ApplicationContextHolder.get();
            SettingManager sm = applicationContext.getBean(SettingManager.class);
            List<String> to = new ArrayList<>();
            to.add(sendTo);
            MailUtil.sendMail(to, subject, message, null, sm, replyTo, replyToDescr);
        }
    }
}
