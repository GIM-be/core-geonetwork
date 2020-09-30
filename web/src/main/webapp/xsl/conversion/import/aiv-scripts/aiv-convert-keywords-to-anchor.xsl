<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="2.0" exclude-result-prefixes="#all">

  <xsl:variable name="iso3charLang"
                select="/gmd:MD_Metadata/gmd:language/gmd:LanguageCode/@codeListValue|/gmd:MD_Metadata/gmd:language/gco:CharacterString/text()"/>

  <xsl:variable name="iso2charLang">
    <xsl:choose>
      <xsl:when test="$iso3charLang = 'dut'">
        <xsl:value-of select="'nl'"/>
      </xsl:when>
      <xsl:when test="$iso3charLang = 'eng'">
        <xsl:value-of select="'en'"/>
      </xsl:when>
      <xsl:when test="$iso3charLang = 'fre' or $iso3charLang = 'fra'">
        <xsl:value-of select="'fr'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'nl'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!--xsl:variable name="baseIso19139" select="'../../../../WEB-INF/data/config/schema_plugins/iso19139/thesauri-AIV/'"/-->
  <xsl:variable name="baseIso19139" select="'../thesauri-AIV/'"/>

  <xsl:variable name="thesaurusList">
    <path><xsl:value-of select="concat($baseIso19139, 'theme/featureconcept.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/GDI-Vlaanderen-service-types.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/GDI-Vlaanderen-trefwoorden.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/gemet.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/inspire-service-taxonomy.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/inspire-theme.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/PriorityDataset.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'place/GDI-Vlaanderenregios.rdf')"/></path>
  </xsl:variable>

  <xsl:variable name="thesauri">
    <xsl:for-each select="$thesaurusList/path">
      <xsl:variable name="currentDoc" select="document(.)"/>
      <thesausus>
        <xsl:attribute name="title" select="string($currentDoc/rdf:RDF/skos:ConceptScheme/dc:title[1])"/>
        <xsl:for-each select="$currentDoc/rdf:RDF/skos:Concept">
          <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="skos:prefLabel[@xml:lang = ($iso2charLang,'en','de','nl','fr')]"/>
          </xsl:copy>
        </xsl:for-each>
      </thesausus>
    </xsl:for-each>
  </xsl:variable>

  <xsl:variable name="inspireThemesStartStringForKeywordMapping">GEMET - INSPIRE them</xsl:variable>
  <xsl:variable name="taxonomyStartStringForKeywordMapping">Verordening (EG) nr. 1205/2008</xsl:variable>
  <xsl:variable name="gdiVlaanderenTrefwoordenStartStringForKeywordMapping">GDI-Vlaanderen Trefwoorden</xsl:variable>
  <xsl:variable name="gdiVlaanderenServiceTypesStartStringForKeywordMapping">GDI-Vlaanderen Service Types</xsl:variable>
  <xsl:variable name="gdiVlaanderenRegiosStartStringForKeywordMapping">Vlaamse regio</xsl:variable>

  <xsl:variable name="inspireThemesStartStringToBeMapped">GEMET - INSPIRE them</xsl:variable>
  <xsl:variable name="taxonomyStartStringToBeMapped">D.4 van de verordening (EG) NR. 1205/2008</xsl:variable>

  <xsl:template match="gmd:MD_Keywords[gmd:thesaurusName and (gmd:keyword/gco:CharacterString or gmd:keyword/gmx:Anchor)]" priority="1000">
    <xsl:variable name="thesaurusTitle" select="gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[name()='gco:CharacterString' or name()='gmx:Anchor']"/>
    <xsl:variable name="mappedThesaurusTitle">
      <xsl:call-template name="mapThesaurusTitle">
        <xsl:with-param name="thesaurusTitle" select="$thesaurusTitle"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="currentThesaurus" select="$thesauri/thesausus[@title = $mappedThesaurusTitle]"/>
    <xsl:message select="concat('Transforming keywords for thesaurus with name ',$thesaurusTitle,' (mapped to ',$mappedThesaurusTitle,') started')" />
    <xsl:copy copy-namespaces="no">
      <xsl:for-each select="gmd:keyword">
        <xsl:variable name="keyword" select="normalize-space(*[name()='gco:CharacterString' or name()='gmx:Anchor'])"/>
        <xsl:message select="concat('Handling keyword ', $keyword)" />
        <xsl:choose>
          <xsl:when test="gmx:Anchor">
            <xsl:variable name="xlink" select="gmx:Anchor/@xlink:href"/>
            <xsl:message select="concat('It is a gmx:Anchor with link ', $xlink)" />
            <xsl:choose>
              <xsl:when test="contains($mappedThesaurusTitle,$inspireThemesStartStringForKeywordMapping)">
                <xsl:variable name="mappedXlink">
                  <xsl:call-template name="mapKeywordAnchor">
                    <xsl:with-param name="xlink" select="$xlink"/>
                    <xsl:with-param name="thesaurusTitle" select="$mappedThesaurusTitle"/>
                    <xsl:with-param name="keyword" select="$keyword"/>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:message select="concat('The mapped xlink is ', $mappedXlink)" />
                <xsl:message select="concat('The mapped xlink is different?', $xlink!=$mappedXlink)" />
                <xsl:choose>
                  <xsl:when test="$xlink!=$mappedXlink">
                    <xsl:copy copy-namespaces="no">
                      <xsl:element name="gmx:Anchor">
                        <xsl:attribute name="xlink:href" select="$mappedXlink"/>
                        <xsl:value-of select="$keyword"/>
                      </xsl:element>
                    </xsl:copy>
                    <xsl:message select="concat('The xlink:href attribute ', $xlink,' of the gmx:Anchor keyword ',$keyword,' is mapped to ', $mappedXlink)" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="." copy-namespaces="no"/>
                    <xsl:message select="concat('The xlink:href attribute ', $xlink, ' of the gmx:Anchor keyword ',$keyword,' is not mapped')" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="." copy-namespaces="no"/>
                <xsl:message select="concat('The xlink:href attribute ', $xlink, ' of the gmx:Anchor keyword ',$keyword,' is not mapped and is already ok')" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="starts-with($mappedThesaurusTitle,$taxonomyStartStringForKeywordMapping)">
            <!--xsl:variable name="keywordListToMap">('humanCatalogueViewer',
              'humanGeographicViewer',
              'humanGeographicSpreadsheetViewer',
              'humanChainDefinitionEditor',
              'humanWorkflowEnactmentManager',
              'humanGeographicFeatureEditor',
              'humanGeographicSymbolEditor',
              'humanFeatureGeneralizationEditor',
              'humanGeographicDataStructureViewer',
              'infoManagementService',
              'infoFeatureAccessService',
              'infoMapAccessService',
              'infoCoverageAccessService',
              'infoSensorDescriptionService',
              'infoProductAccessService',
              'infoFeatureTypeService',
              'infoCatalogueService',
              'infoRegistryService',
              'infoGazetteerService',
              'infoOrderHandlingService',
              'infoStandingOrderService',
              'taskManagementService',
              'chainDefinitionService',
              'workflowEnactmentService',
              'subscriptionService',
              'spatialProcessingService',
              'spatialCoordinateConversionService',
              'spatialCoordinateTransformationService',
              'spatialCoverageVectorConversionService',
              'spatialImageCoordinateConversionService',
              'spatialRectificationService',
              'spatialOrthorectificationService',
              'spatialSensorGeometryModelAdjustmentService',
              'spatialImageGeometryModelConversionService',
              'spatialSubsettingService',
              'spatialSamplingService',
              'spatialTilingChangeService',
              'spatialDimensionMeasurementService',
              'spatialFeatureManipulationService',
              'spatialFeatureMatchingService',
              'spatialFeatureGeneralizationService',
              'spatialRouteDeterminationService',
              'spatialPositioningService',
              'spatialProximityAnalysisService',
              'thematicProcessingService',
              'thematicGoparameterCalculationService',
              'thematicClassificationService',
              'thematicFeatureGeneralizationService',
              'thematicSubsettingService',
              'thematicSpatialCountingService',
              'thematicChangeDetectionService',
              'thematicGeographicInformationExtractionService',
              'thematicImageProcessingService',
              'thematicReducedResolutionGenerationService',
              'thematicImageManipulationService',
              'thematicImageUnderstandingService',
              'thematicImageSynthesisService',
              'thematicMultibandImageManipulationService',
              'thematicObjectDetectionService',
              'thematicGeoparsingService',
              'thematicGeocodingService',
              'temporalProcessingService',
              'temporalReferenceSystemTransformationService',
              'temporalSubsettingService',
              'temporalSamplingService',
              'temporalProximityAnalysisService',
              'metadataProcessingService',
              'metadataStatisticalCalculationService',
              'metadataGeographicAnnotationService',
              'comService',
              'comEncodingService',
              'comTransferService',
              'comGeographicCompressionService',
              'comGeographicFormatConversionService',
              'comMessagingService',
              'comRemoteFileAndExecutableManagement')</xsl:variable-->
            <xsl:variable name="concept" select="$currentThesaurus/skos:Concept[ends-with(@rdf:about,$keyword)]" />
            <xsl:variable name="rdfAboutNL" select="$concept/skos:prefLabel[@xml:lang = 'nl']" />
            <xsl:choose>
              <xsl:when test="$rdfAboutNL!=''">
                <xsl:message select="concat('The new concept is found ', $concept/@rdf:about)" />
                <xsl:copy copy-namespaces="no">
                  <xsl:element name="gmx:Anchor">
                    <xsl:attribute name="xlink:href" select="$concept/@rdf:about"/>
                    <xsl:value-of select="$rdfAboutNL"/>
                  </xsl:element>
                </xsl:copy>
                <xsl:message select="concat('The gco:CharacterString keyword ',$keyword,' is transformed to a gmx:Anchor with xlink:href ', $concept/@rdf:about)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="." copy-namespaces="no"/>
                <xsl:message select="concat('The gco:CharacterString keyword ',$keyword,' is not transformed to a gmx:Anchor')" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="concat('It is a gco:CharacterString ', $keyword)" />
            <xsl:variable name="xlink">
              <xsl:call-template name="findConcept">
                <xsl:with-param name="keyword" select="$keyword"/>
                <xsl:with-param name="thesaurus" select="$currentThesaurus"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$xlink!=''">
                <xsl:message select="concat('The concept is found ', $xlink)" />
                <xsl:copy copy-namespaces="no">
                  <xsl:element name="gmx:Anchor">
                    <xsl:attribute name="xlink:href" select="$xlink"/>
                    <xsl:value-of select="$keyword"/>
                  </xsl:element>
                </xsl:copy>
                <xsl:message select="concat('The gco:CharacterString keyword ',$keyword,' is transformed to a gmx:Anchor with xlink:href ', $xlink)" />
              </xsl:when>
              <xsl:when test="$keyword=''">
                <xsl:message select="'The concept was not found because the keyword is empty'" />
                <xsl:copy copy-namespaces="no">
                  <xsl:attribute name="gco:nilReason" select="'missing'"/>
                  <xsl:element name="gmx:Anchor">
                    <xsl:attribute name="xlink:href" select="''"/>
                  </xsl:element>
                </xsl:copy>
                <xsl:message select="concat('The empty gco:CharacterString keyword ',$keyword,' is transformed to an empty gmx:Anchor with empty xlink:href ')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="." copy-namespaces="no"/>
                <xsl:message select="concat('The gco:CharacterString keyword ',$keyword,' is not transformed to a gmx:Anchor')" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:message select="concat('Transforming keywords for thesaurus with name ',$thesaurusTitle,' (mapped to ', $mappedThesaurusTitle,') ended')" />
      <xsl:apply-templates select="gmd:type"/>
      <xsl:apply-templates select="gmd:thesaurusName"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:type" priority="1000">
    <xsl:variable name="thesaurusTitle" select="../gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[name(.)=('gco:CharacterString','gmx:Anchor')]/string()"/>
    <xsl:variable name="codeListValue">
      <xsl:choose>
        <xsl:when test="@codeListValue!=''"><xsl:value-of select="@codeListValue"/></xsl:when>
        <xsl:when test="contains($thesaurusTitle,'Vlaamse regio')">place</xsl:when>
        <xsl:otherwise>theme</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy copy-namespaces="no">
      <gmd:MD_KeywordTypeCode codeListValue="{$codeListValue}"
                              codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_KeywordTypeCode"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:thesaurusName/gmd:CI_Citation/gmd:title[gmx:Anchor or gco:CharacterString]" priority="1000">
    <xsl:copy copy-namespaces="no">
      <xsl:variable name="thesaurusTitle" select="*[name()='gco:CharacterString' or name()='gmx:Anchor']"/>
      <xsl:variable name="mappedThesaurusTitle">
        <xsl:call-template name="mapThesaurusTitle">
          <xsl:with-param name="thesaurusTitle" select="$thesaurusTitle"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="contains($mappedThesaurusTitle,$inspireThemesStartStringForKeywordMapping)">
          <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/theme"><xsl:value-of select="$mappedThesaurusTitle"/></gmx:Anchor>
        </xsl:when>
        <xsl:when test="starts-with($mappedThesaurusTitle,$taxonomyStartStringForKeywordMapping)">
          <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory"><xsl:value-of select="$mappedThesaurusTitle"/></gmx:Anchor>
        </xsl:when>
        <xsl:when test="starts-with($mappedThesaurusTitle,$gdiVlaanderenTrefwoordenStartStringForKeywordMapping)">
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden"><xsl:value-of select="$mappedThesaurusTitle"/></gmx:Anchor>
        </xsl:when>
        <xsl:when test="starts-with($mappedThesaurusTitle,$gdiVlaanderenServiceTypesStartStringForKeywordMapping)">
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Service-Types"><xsl:value-of select="$mappedThesaurusTitle"/></gmx:Anchor>
        </xsl:when>
        <xsl:when test="starts-with($mappedThesaurusTitle,$gdiVlaanderenRegiosStartStringForKeywordMapping)">
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Vlaamse-Administratieve-Eenheden"><xsl:value-of select="$mappedThesaurusTitle"/></gmx:Anchor>
        </xsl:when>
        <xsl:otherwise><xsl:apply-templates select="*"/></xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="mapThesaurusTitle">
    <xsl:param name="thesaurusTitle" required="yes"/>
    <xsl:choose>
      <xsl:when test="contains($thesaurusTitle,$inspireThemesStartStringToBeMapped)">GEMET - INSPIRE themes, version 1.0</xsl:when>
      <xsl:when test="starts-with($thesaurusTitle, $taxonomyStartStringToBeMapped)">Verordening (EG) nr. 1205/2008 van de Commissie van 3 december 2008 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende metagegevens</xsl:when>
      <xsl:otherwise><xsl:value-of select="$thesaurusTitle"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mapKeywordAnchor">
    <xsl:param name="xlink" required="yes"/>
    <xsl:param name="thesaurusTitle" required="yes"/>
    <xsl:param name="keyword"/>
    <xsl:choose>
      <xsl:when test="contains($thesaurusTitle,$inspireThemesStartStringForKeywordMapping)">
        <xsl:choose>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/4'">http://inspire.ec.europa.eu/theme/au</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/5'">http://inspire.ec.europa.eu/theme/ad</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/26'">http://inspire.ec.europa.eu/theme/ac</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/9'">http://inspire.ec.europa.eu/theme/ps</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/30'">http://inspire.ec.europa.eu/theme/br</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/16'">http://inspire.ec.europa.eu/theme/so</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/11'">http://inspire.ec.europa.eu/theme/lc</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/33'">http://inspire.ec.europa.eu/theme/er</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/22'">http://inspire.ec.europa.eu/theme/af</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/21'">http://inspire.ec.europa.eu/theme/pf</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/25'">http://inspire.ec.europa.eu/theme/nz</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/24'">http://inspire.ec.europa.eu/theme/am</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/15'">http://inspire.ec.europa.eu/theme/bu</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/2'">http://inspire.ec.europa.eu/theme/gg</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/3'">http://inspire.ec.europa.eu/theme/gn</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/13'">http://inspire.ec.europa.eu/theme/ge</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/31'">http://inspire.ec.europa.eu/theme/hb</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/10'">http://inspire.ec.europa.eu/theme/el</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/8'">http://inspire.ec.europa.eu/theme/hy</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/6'">http://inspire.ec.europa.eu/theme/cp</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/17'">http://inspire.ec.europa.eu/theme/lu</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/18'">http://inspire.ec.europa.eu/theme/hh</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/27'">http://inspire.ec.europa.eu/theme/mf</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/20'">http://inspire.ec.europa.eu/theme/ef</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/34'">http://inspire.ec.europa.eu/theme/mr</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/19'">http://inspire.ec.europa.eu/theme/us</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/28'">http://inspire.ec.europa.eu/theme/of</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/12'">http://inspire.ec.europa.eu/theme/oi</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/23'">http://inspire.ec.europa.eu/theme/pd</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/32'">http://inspire.ec.europa.eu/theme/sd</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/14'">http://inspire.ec.europa.eu/theme/su</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/1'">http://inspire.ec.europa.eu/theme/rs</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/7'">http://inspire.ec.europa.eu/theme/tn</xsl:when>
          <xsl:when test="$xlink='http://rdfdata.eionet.europa.eu/inspirethemes/themes/29'">http://inspire.ec.europa.eu/theme/sr</xsl:when>
          <xsl:otherwise><xsl:value-of select="$xlink"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$xlink"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="findConcept">
    <xsl:param name="keyword" required="yes"/>
    <xsl:param name="thesaurus" required="yes"/>
    <xsl:variable name="rdfAboutInMdLanguage" select="$thesaurus/skos:Concept[skos:prefLabel[@xml:lang = $iso2charLang] = $keyword]/@rdf:about" />
    <xsl:variable name="rdfAboutNL" select="$thesaurus/skos:Concept[skos:prefLabel[@xml:lang = 'nl'] = $keyword]/@rdf:about" />
    <xsl:variable name="rdfAboutEN" select="$thesaurus/skos:Concept[skos:prefLabel[@xml:lang = 'en'] = $keyword]/@rdf:about" />
    <xsl:choose>
      <xsl:when test="$rdfAboutInMdLanguage">
        <xsl:value-of select="$rdfAboutInMdLanguage"/>
      </xsl:when>
      <xsl:when test="$rdfAboutNL">
        <xsl:value-of select="$rdfAboutNL"/>
      </xsl:when>
      <xsl:when test="$rdfAboutEN">
        <xsl:value-of select="$rdfAboutEN"/>
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
