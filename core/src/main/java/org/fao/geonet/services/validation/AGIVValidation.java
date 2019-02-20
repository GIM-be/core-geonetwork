package org.fao.geonet.services.validation;

import jeeves.server.context.ServiceContext;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.domain.*;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.repository.MetadataRepository;
import org.fao.geonet.repository.MetadataValidationRepository;
import org.fao.geonet.repository.Updater;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.Namespace;

import javax.annotation.Nonnull;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

/**
 * Records validation result inside the metadata itself.
 * <p>
 * NOTE: the valTypeAndStatus map contains the validation summary, same as it is saved to the DB. Its structure is:
 * <p>
 * key : string. Name of validation type. E.g. "xsd", "schematron-rules-iso", "schematron-rules-inspire"
 * value: array of 3 integers where
 * value[0] : can be 1 or 0, meaning validation succeeded (1) or failed (0).
 * value[1] : only applicable to schematron validation types. Total number of asserts in this validation.
 * value[2] : only applicable to schematron validation types. Number of failed asserts in this validation.
 *
 * @author heikki doeleman
 */
public class AGIVValidation {
    private GeonetContext gc;
    private DataManager dm;

    public static final String INSPIRE_SCHEMATRON_KEY = "schematron-rules-inspire";
    public static final String AGIV_SCHEMATRON_KEY = "schematron-rules-GDI-Vlaanderen";

    //
    // XSLT file names
    //

    private static final String ADD_INSPIRE_KEYWORD = "agiv-add-inspire-keyword.xsl";
    private static final String REMOVE_INSPIRE_KEYWORD = "agiv-remove-inspire-keyword.xsl";

    private static final String ADD_AGIV_KEYWORD = "agiv-add-agiv-keyword.xsl";
    private static final String REMOVE_AGIV_KEYWORD = "agiv-remove-agiv-keyword.xsl";

    public AGIVValidation(ServiceContext context) {
        gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
        dm = gc.getBean(DataManager.class);
    }

    /**
     * Invoked when validation has finished. The arguments should be :
     * - the metadata
     * - a boolean if needs to update the database from within this function
     * @param metadata
     * @param save
     * @return Pair containing a boolean (true if the metadata has changed, false otherwise) and the changed metadata
     * @throws ValidationHookException hmm
     */
    public Pair<Boolean, AbstractMetadata> addConformKeywords(AbstractMetadata metadata, boolean save) throws ValidationHookException {
        try {
            Pair result = addConformKeywordsToElement(
                metadata.getXmlData(false),
                metadata.getDataInfo().getSchemaId(),
                metadata.getId()
            );

            if((Boolean)result.one()) {
                if(save) {
                    metadata = gc.getBean(MetadataRepository.class).update(metadata.getId(), new Updater<Metadata>() {
                        @Override
                        public void apply(@Nonnull Metadata entity) {
                            entity.setDataAndFixCR((Element)result.two());
                        }
                    });
                } else {
                    metadata.setDataAndFixCR((Element)result.two());
                }
            }
            return Pair.read((Boolean)result.one(), metadata);
        } catch (Exception x) {
            System.out.println("AGIVValidation NOK");
            throw new ValidationHookException(x.getMessage(), x);
        }
    }

    /**
     * Invoked when validation has finished. The arguments should be :
     * - the metadata ID
     * - a boolean if needs to update the database from within this function
     * @param metadataId
     * @param save
     * @return Pair containing a boolean (true if the metadata has changed, false otherwise) and the changed metadata
     * @throws ValidationHookException hmm
     */
    public Pair<Boolean, AbstractMetadata> addConformKeywords(String metadataId, boolean save) throws ValidationHookException {
        final MetadataRepository metadataRepository = gc.getBean(MetadataRepository.class);
        return addConformKeywords(metadataRepository.findOne(metadataId), save);
    }


    /**
     * @param mdElement
     * @param schema
     * @param mdId
     * @throws ValidationHookException
     */
    public Pair<Boolean, Element> addConformKeywordsToElement(Element mdElement, String schema, int mdId) throws ValidationHookException {
        try {
            final MetadataValidationRepository metadataValidationRepository = gc.getBean(MetadataValidationRepository.class);
            List<MetadataValidation> metadataValidations = metadataValidationRepository.findAllById_MetadataId(mdId);
            Element mdTemp = mdElement;

            mdElement = logINSPIRECompliance(mdElement, schema, findValidation(metadataValidations, INSPIRE_SCHEMATRON_KEY));
            mdElement = logAGIVCompliance(mdElement, schema, findValidation(metadataValidations, AGIV_SCHEMATRON_KEY));
            boolean changed = !mdElement.equals(mdTemp);

            return Pair.read(changed, mdElement);
        } catch (Exception e) {
            System.out.println("AGIVValidation NOK");
            throw new ValidationHookException(e.getMessage(), e);
        }
    }

    /**
     * Adds or removes keyword to indicate INSPIRE compliance.
     * <p>
     * AGIV mss120716v01_D2200 9_Stepped_MetadataValidation_c110148_M12ss006v031.doc § 4.2 :
     * <p>
     * Conformity against the INSPIRE Metadata Implementing Rule for datasets, dataset series and services. This is
     * verified by checking against the INSPIRE schematrons and will happen for dataset (series) and services metadata.
     * <p>
     * If the metadata is conforming to INSPIRE the keyword 'Conform INSPIRE – Metadata Implementing Rules' is added to
     * the list of available keywords with as thesaurus 'GDI-Vlaanderen Trefwoorden' with thesaurus date '2012-07-10'.
     * <p>
     * Obviously it will first be checked if this keyword is already present to avoid duplicate keywords. In case the
     * metadata is not conforming, the list of keywords will be checked and the above mentioned keyword removed - if it
     * was present.
     *
     * @param metadata
     * @param schema
     * @param inspireValidation
     * @throws ValidationHookException
     */
    private Element logINSPIRECompliance(Element metadata, String schema, MetadataValidation inspireValidation) throws Exception {
        if(inspireValidation == null) {
            return metadata;
        }
        if(inspireValidation.getStatus() == MetadataValidationStatus.VALID) {
            metadata = transformMd(metadata, schema, ADD_INSPIRE_KEYWORD);
        }
        else {
            metadata = transformMd(metadata, schema, REMOVE_INSPIRE_KEYWORD);
        }
        return metadata;
    }

    /**
     * Adds or removes keyword to indicate AGIV compliance.
     * <p>
     * AGIV mss120716v01_D2200 9_Stepped_MetadataValidation_c110148_M12ss006v031.doc § 4.2 :
     * <p>
     * Conformity against the GDI-Vlaanderen Best Practices. This is verified by checking against the GDI-Vlaanderen
     * schematrons.
     * <p>
     * If the metadata is conforming, the keyword 'Conform GDI-Vlaanderen Best Practices' is added to the list of
     * available keywords with as thesaurus 'GDI-Vlaanderen Trefwoorden' and as thesaurus date '2012-07-10'.
     * <p>
     * In case the metadata is not conforming, the list of keywords will be checked and the above mentioned keyword is
     * removed, if it was present. Obviously it will first be checked if this keyword is already present to avoid
     * duplicate keywords.
     *
     * @param metadata
     * @param schema
     * @param agivValidation
     * @throws ValidationHookException
     */
    private Element logAGIVCompliance(Element metadata, String schema, MetadataValidation agivValidation) throws Exception {
        if(agivValidation == null) {
            return metadata;
        }
        if(agivValidation.getStatus() == MetadataValidationStatus.VALID) {
            metadata = transformMd(metadata, schema, ADD_AGIV_KEYWORD);
        }
        else {
            metadata = transformMd(metadata, schema, REMOVE_AGIV_KEYWORD);
        }
        return metadata;
    }


    /**
     * @param md
     * @param schema
     * @param styleSheet
     * @throws Exception
     */
    private Element transformMd(Element md, String schema, String styleSheet) throws Exception {
        Path xslt = dm.getSchemaDir(schema).resolve(styleSheet);
        return Xml.transform(md, xslt);
    }


    /**
     * Returns value of /gmd:Metadata/gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue.
     *      *
     * @param metadata
     * @return
     * @throws JDOMException
     */
    private String getHierarchyLevel(Element metadata) throws JDOMException {
        List<Namespace> nsList = new ArrayList<Namespace>(2);
        nsList.add(Namespace.getNamespace("gmd", "http://www.isotc211.org/2005/gmd"));
        nsList.add(Namespace.getNamespace("gco", "http://www.isotc211.org/2005/gco"));
        String level = Xml.selectString(metadata, "//gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue", nsList);
        return level;
    }


    /**
     * Return one element of the MetadataValidation List
     *
     * @param metadataValidations
     * @param validationId
    */
    private MetadataValidation findValidation(List<MetadataValidation> metadataValidations, String validationId) {
        return metadataValidations.stream()
            .filter(metadataValidation -> validationId.equals(metadataValidation.getId().getValidationType()))
            .findFirst()
            .orElse(null);
    }
}
