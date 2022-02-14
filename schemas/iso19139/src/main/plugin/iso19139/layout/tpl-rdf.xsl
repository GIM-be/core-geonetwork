<?xml version="1.0" encoding="UTF-8"?>

<!--

  Copyright 2015-2017 EUROPEAN UNION
  Licensed under the EUPL, Version 1.1 or - as soon they will be approved by
  the European Commission - subsequent versions of the EUPL (the "Licence");
  You may not use this work except in compliance with the Licence.
  You may obtain a copy of the Licence at:

  http://ec.europa.eu/idabc/eupl

  Unless required by applicable law or agreed to in writing, software
  distributed under the Licence is distributed on an "AS IS" basis,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the Licence for the specific language governing permissions and
  limitations under the Licence.

  Authors:      European Commission - Joint Research Centre
                Andrea Perego <andrea.perego@ec.europa.eu>

  Contributors: ISA GeoDCAT-AP Working Group
                <dcat_application_profile-geo@joinup.ec.europa.eu>

  This work was supported by the EU Interoperability Solutions for
  European Public Administrations Programme (http://ec.europa.eu/isa)
  through Action 1.17: Re-usable INSPIRE Reference Platform
  (http://ec.europa.eu/isa/actions/01-trusted-information-exchange/1-17action_en.htm).

-->

<!--

  PURPOSE AND USAGE

  This XSLT is a proof of concept for the implementation of the specification
  concerning the geospatial profile of DCAT-AP (GeoDCAT-AP), available on
  Joinup, the collaboration platform of the EU ISA Programme:

    https://joinup.ec.europa.eu/node/139283/

  As such, this XSLT must be considered as unstable, and can be updated any
  time based on the revisions to the GeoDCAT-AP specifications and
  related work in the framework of INSPIRE and the EU ISA Programme.

-->

<!--
  Modified by GIM
  Source XSL: https://github.com/SEMICeu/iso-19139-to-dcat-ap/blob/master/iso-19139-to-dcat-ap.xsl
-->

<xsl:stylesheet xmlns:adms="http://www.w3.org/ns/adms#"
                xmlns:cnt="http://www.w3.org/2011/content#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:dctype="http://purl.org/dc/dcmitype/"
                xmlns:earl="http://www.w3.org/ns/earl#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:locn="http://www.w3.org/ns/locn#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:schema="http://schema.org/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:geodcat="http://data.europa.eu/930/"
                xmlns:mdcat="http://data.vlaanderen.be/ns/metadata-dcat#"
                xmlns:adres="https://data.vlaanderen.be/ns/adres#"
                xmlns:vlgen="https://data.vlaanderen.be/ns/generiek"
                xmlns:xslutil="java:org.fao.geonet.util.XslUtil"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:output method="xml"
              indent="yes"
              encoding="utf-8"
              cdata-section-elements="" />

  <xsl:include href="../convert/keyword_CharacterString_to_Anchor.xsl"/>
  <xsl:include href="../convert/TopicCatToDataGov.xsl"/>

  <xsl:include href="tpl-rdf-utils.xsl"/>
  <xsl:include href="tpl-rdf-variables.xsl"/>

  <!--
    Metadata template
    =================
   -->
  <xsl:template match="gmd:MD_Metadata|//gmd:MD_Metadata" mode="to-dcat">
    <xsl:variable name="MetadataViewUrl" select="concat($catalogUrl, '/catalog.search#/metadata/', gmd:fileIdentifier/gco:CharacterString)"/>

    <xsl:variable name="MetadataXmlUrl" select="concat(substring-before($resourcePrefix, '/resource'), '/api/records/', gmd:fileIdentifier/gco:CharacterString, '/formatters/xml')"/>

    <!-- Metadata language: corresponding Alpha-2 codes -->
    <xsl:variable name="RecordLang">
      <xsl:call-template name="ExtractLang">
        <xsl:with-param name="lang" select="gmd:language"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="MetadataLanguage">
      <xsl:call-template name="Alpha3-to-Alpha2">
        <xsl:with-param name="lang" select="$RecordLang"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="IsoScopeCode">
      <xsl:value-of select="normalize-space(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)"/>
    </xsl:variable>

    <xsl:variable name="ResourceType">
      <xsl:choose>
        <xsl:when test="$IsoScopeCode = 'dataset' or $IsoScopeCode = 'nonGeographicDataset'">
          <xsl:text>dataset</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$IsoScopeCode"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="ServiceType">
      <xsl:value-of select="gmd:identificationInfo/*/srv:serviceType/gco:LocalName"/>
    </xsl:variable>

    <xsl:variable name="ResourceTitle">
      <xsl:for-each select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:title">
        <dct:title xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(gco:CharacterString)"/>
        </dct:title>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">dct:title</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="ResourceAbstract">
      <xsl:for-each select="gmd:identificationInfo[1]/*/gmd:abstract">
        <dct:description xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(gco:CharacterString)"/>
        </dct:description>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">dct:description</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="MetadataDate" select="geonet:formatRdfDate(gmd:dateStamp/*)"/>

    <xsl:variable name="RecordUUID" select="string(gmd:fileIdentifier/gco:CharacterString)"/>

    <xsl:variable name="ResourceUUID" select="geonet:getResourceUuid(.)"/>

    <xsl:variable name="uriPattern" select="xslutil:getUriPattern($RecordUUID)"/>

    <xsl:variable name="RecordURI">
      <xsl:variable name="mURI" select="replace(replace($uriPattern, '\{resourceType\}', 'records'), '\{resourceUuid\}', $RecordUUID)"/>
      <xsl:if test="$mURI != '' and (starts-with($mURI, 'http://') or starts-with($mURI, 'https://'))">
        <xsl:value-of select="geonet:escapeURI($mURI)"/>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="ResourceUri" select="geonet:getResourceURI(., $ResourceType, $uriPattern)"/>

    <xsl:variable name="LicenseAndRightsConstraints">
      <xsl:variable name="constraints" select="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:otherConstraints[../gmd:useConstraints or ../gmd:accessConstraints]/*|
                                               gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:useLimitation[not(../gmd:useConstraints or ../gmd:accessConstraints)]/*"/>

      <!-- Pick the first model license and map it to dct:license -->
      <xsl:variable name="modelLicences">
        <xsl:for-each select="$constraints[name() = 'gmx:Anchor']">
          <xsl:variable name="currentUrl" select="translate(@xlink:href, $uppercase, $lowercase)"/>
          <xsl:variable name="modelLicence" select="$modelLicencieKeywords/license[count(urlKeyword[contains($currentUrl, .)]) > 0 and (not(scope) or count(scope[$ResourceType = .]) > 0)]/content/*"/>
          <xsl:if test="$modelLicence">
            <xsl:copy-of select="$modelLicence"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:if test="normalize-space($modelLicences) != ''">
        <xsl:copy-of select="$modelLicences/*[1]"/>
      </xsl:if>

      <!-- Map all the other constraints to dct:rights -->
      <xsl:for-each select="$constraints">
        <xsl:variable name="currentUrl" select="translate(@xlink:href, $uppercase, $lowercase)"/>
        <xsl:variable name="modelLicence" select="$modelLicencieKeywords/license[count(urlKeyword[contains($currentUrl, .)]) > 0 and (not(scope) or count(scope[$ResourceType = .]) > 0)]/content/*"/>
        <xsl:if test="not($modelLicence)">
          <dct:rights>
            <dct:RightsStatement>
              <xsl:if test="name() = 'gmx:Anchor'">
                <xsl:attribute name="rdf:about" select="@xlink:href"/>
              </xsl:if>
              <dct:title>
                <xsl:value-of select="string()"/>
              </dct:title>
            </dct:RightsStatement>
          </dct:rights>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="AccessRights">
      msg
      <!-- Mapping revised for compliance with the 2017 edition of the INSPIRE Metadata Technical Guidelines -->
      <xsl:variable name="firstConstraint" select="gmd:identificationInfo[count(*/gmd:resourceConstraints/*/gmd:accessConstraints) > 0]/*/gmd:resourceConstraints/*"/>
      <xsl:choose>
        <xsl:when test="count($firstConstraint/gmd:otherConstraints/gmx:Anchor/@xlink:href[. = ('http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations','https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations')]) > 0">
          <dct:accessRights>
            <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/access-right/PUBLIC">
              <rdf:type rdf:resource="http://purl.org/dc/terms/RightsStatement"/>
              <xsl:choose>
                <xsl:when test="$ResourceType = 'service'">
                  <skos:prefLabel xml:lang="nl">zonder voorwaarden</skos:prefLabel>
                  <skos:prefLabel xml:lang="en">without conditions</skos:prefLabel>
                  <skos:prefLabel xml:lang="fr">without conditions</skos:prefLabel>
                  <skos:prefLabel xml:lang="de">without conditions</skos:prefLabel>
                </xsl:when>
                <xsl:otherwise>
                  <skos:prefLabel xml:lang="nl">publiek</skos:prefLabel>
                  <skos:prefLabel xml:lang="en">public</skos:prefLabel>
                  <skos:prefLabel xml:lang="fr">public</skos:prefLabel>
                  <skos:prefLabel xml:lang="de">public</skos:prefLabel>
                </xsl:otherwise>
              </xsl:choose>
              <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/access-right"/>
            </skos:Concept>
          </dct:accessRights>
        </xsl:when>
        <xsl:otherwise>
          <dct:accessRights>
            <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/access-right/NON_PUBLIC">
              <rdf:type rdf:resource="http://purl.org/dc/terms/RightsStatement"/>
              <xsl:choose>
                <xsl:when test="$ResourceType = 'service'">
                  <skos:prefLabel xml:lang="nl">met voorwaarden</skos:prefLabel>
                  <skos:prefLabel xml:lang="en">with conditions</skos:prefLabel>
                  <skos:prefLabel xml:lang="fr">with conditions</skos:prefLabel>
                  <skos:prefLabel xml:lang="de">with conditions</skos:prefLabel>
                </xsl:when>
                <xsl:otherwise>
                  <skos:prefLabel xml:lang="nl">niet publiek</skos:prefLabel>
                  <skos:prefLabel xml:lang="en">not public</skos:prefLabel>
                  <skos:prefLabel xml:lang="fr">not public</skos:prefLabel>
                  <skos:prefLabel xml:lang="de">not public</skos:prefLabel>
                </xsl:otherwise>
              </xsl:choose>
              <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/access-right"/>
            </skos:Concept>
          </dct:accessRights>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Metadata character encoding -->
    <xsl:variable name="MetadataCharacterEncoding">
      <xsl:apply-templates select="gmd:characterSet/gmd:MD_CharacterSetCode"/>
    </xsl:variable>

    <xsl:variable name="ResourceCharacterEncoding">
      <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification">
        <xsl:apply-templates select="gmd:characterSet/gmd:MD_CharacterSetCode"/>
      </xsl:for-each>
    </xsl:variable>

    <!-- Metadata description (metadata on metadata) -->
    <xsl:variable name="MetadataDescription">
      <dct:identifier>
        <xsl:value-of select="$RecordUUID"/>
      </dct:identifier>

      <xsl:if test="$RecordLang != ''">
        <xsl:variable name="languageConcept">
          <xsl:call-template name="Map-language">
            <xsl:with-param name="lang" select="translate($RecordLang, $lowercase, $uppercase)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="normalize-space($languageConcept) != ''">
            <dct:language>
              <xsl:copy-of select="$languageConcept"/>
            </dct:language>
          </xsl:when>
          <xsl:otherwise>
            <dct:language rdf:resource="{geonet:escapeURI(concat($oplang, translate($RecordLang, $lowercase, $uppercase)))}"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="$MetadataDate != ''">
        <dct:modified>
          <xsl:value-of select="$MetadataDate"/>
        </dct:modified>
      </xsl:if>

      <dct:conformsTo>
        <dct:Standard rdf:about="https://data.vlaanderen.be/doc/applicatieprofiel/GEODCAT-AP-VL/">
          <dct:title>Geodcat-ap-vl</dct:title>
        </dct:Standard>
      </dct:conformsTo>

      <dct:source rdf:resource="{$MetadataXmlUrl}"/>
      <dcat:landingPage rdf:resource="{$MetadataViewUrl}"/>

      <xsl:if test="$MetadataCharacterEncoding != ''">
        <xsl:copy-of select="$MetadataCharacterEncoding"/>
      </xsl:if>
    </xsl:variable>

    <!-- Resource description (resource metadata) -->
    <xsl:variable name="ResourceDescription">
      <xsl:choose>
        <xsl:when test="$ResourceType = 'dataset'">
          <rdf:type rdf:resource="{$dcat}Dataset"/>
        </xsl:when>
        <xsl:when test="$ResourceType = 'series'">
          <rdf:type rdf:resource="{$dcat}Dataset"/>
        </xsl:when>
        <xsl:when test="$ResourceType = 'service'">
          <xsl:choose>
            <xsl:when test="$ServiceType = 'discovery'">
              <rdf:type rdf:resource="{$dcat}Catalog"/>
            </xsl:when>
            <xsl:otherwise>
              <rdf:type rdf:resource="{$dcat}DataService"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>

      <!-- Unique Resource identification info -->
      <dct:identifier>
        <xsl:value-of select="$ResourceUUID"/>
      </dct:identifier>
      <xsl:copy-of select="$ResourceTitle"/>
      <xsl:copy-of select="$ResourceAbstract"/>

      <!-- Keyword -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <!-- Alternate title -->
      <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:alternateTitle">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <!-- Content information -->
      <xsl:apply-templates select="gmd:contentInfo/*"/>

      <!-- Resource Language -->
      <xsl:for-each select="gmd:identificationInfo/*/gmd:language">
        <xsl:variable name="resLang">
          <xsl:call-template name="ExtractLang">
            <xsl:with-param name="lang" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="normalize-space($resLang) != ''">
          <xsl:variable name="languageConcept">
            <xsl:call-template name="Map-language">
              <xsl:with-param name="lang" select="translate($resLang, $lowercase, $uppercase)"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="normalize-space($languageConcept) != ''">
              <dct:language>
                <xsl:copy-of select="$languageConcept"/>
              </dct:language>
            </xsl:when>
            <xsl:otherwise>
              <dct:language rdf:resource="{geonet:escapeURI(concat($oplang, translate($RecordLang, $lowercase, $uppercase)))}"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>

      <!-- Temporal extent -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"/>

      <!-- Creation date, publication date, date of last revision -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:date/gmd:CI_Date"/>

      <!-- Conformity -->
      <xsl:apply-templates select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/gmd:CI_Citation">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <!-- Responsible organisation -->
      <xsl:for-each select="(.//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'])[1]|
                            (.//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'custodian'])[1]">
        <xsl:apply-templates select=".">
          <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
          <xsl:with-param name="ResourceType" select="$ResourceType"/>
        </xsl:apply-templates>
      </xsl:for-each>

      <xsl:for-each select=".//gmd:CI_ResponsibleParty[not(gmd:role/gmd:CI_RoleCode/@codeListValue = ('publisher', 'distributor', 'custodian'))]">
        <xsl:apply-templates select=".">
          <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
          <xsl:with-param name="ResourceType" select="$ResourceType"/>
        </xsl:apply-templates>
      </xsl:for-each>

      <xsl:variable name="Distributors">
        <xsl:apply-templates select="(.//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'distributor'])[1]">
          <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
          <xsl:with-param name="ResourceType" select="$ResourceType"/>
        </xsl:apply-templates>
      </xsl:variable>

      <!-- Spatial extend -->
      <xsl:apply-templates select="gmd:identificationInfo[1]/*/*[self::gmd:extent|self::srv:extent]/*/gmd:geographicElement/gmd:EX_GeographicBoundingBox"/>

      <!-- spatial resolution -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution"/>

      <!-- Version information -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/*/gmd:edition"/>

      <!-- Access Rights -->
      <xsl:copy-of select="$AccessRights"/>

      <!-- Metadata view page -->
      <dcat:landingPage rdf:resource="{$MetadataViewUrl}"/>

      <!-- Resource type specific -->
      <xsl:choose>
        <!-- Service specific -->
        <xsl:when test="$ResourceType = 'service'">
          <!-- Topic category -->
          <xsl:apply-templates select="gmd:identificationInfo/*/gmd:topicCategory"/>

          <!-- Transfer option -->
          <xsl:variable name="distribution" select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine[
                                                      gmd:CI_OnlineResource/gmd:protocol/gco:CharacterString = ('OGC:WMS', 'OGC:WFS', 'OGC:WCS', 'OGC:WMTS') and
                                                      gmd:CI_OnlineResource/gmd:linkage/gmd:URL
                                                    ][1]/gmd:CI_OnlineResource/gmd:linkage[1]/gmd:URL[1]"/>
          <xsl:if test="$distribution">
            <dcat:endpointDescription rdf:resource="{normalize-space($distribution)}"/>
            <dcat:endpointUrl rdf:resource="{normalize-space(tokenize($distribution, '\?')[1])}"/>
          </xsl:if>

          <!-- Online resources -->
          <xsl:for-each-group select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/*" group-by=".">
            <!-- Conform to standard -->
            <xsl:if test="normalize-space(current-grouping-key()) != ''">
              <!-- TODO: map to INSPIRE-PV codelist values: https://inspire.ec.europa.eu/metadata-codelist/ProtocolValue -->
              <dct:conformsTo>
                <dct:Standard>
                  <dct:identifier>
                    <xsl:value-of select="current-grouping-key()"/>
                  </dct:identifier>
                </dct:Standard>
              </dct:conformsTo>
            </xsl:if>
          </xsl:for-each-group>
          <xsl:copy-of select="$LicenseAndRightsConstraints"/>

          <!-- Coupled resources -->
          <xsl:if test="$relationLookup">
            <xsl:for-each select="xslutil:getRelatedDatasets($RecordUUID)/datasets/*">
              <xsl:choose>
                <xsl:when test="name() = 'gmd:MD_Metadata'">
                  <xsl:variable name="datasetUriPattern" select="xslutil:getUriPattern(gmd:fileIdentifier/gco:CharacterString)"/>
                  <dcat:servesDataset rdf:resource="{geonet:getResourceURI(., 'dataset', $datasetUriPattern)}"/>
                </xsl:when>
                <xsl:when test="name() = 'rdf:RDF'">
                  <dct:relation rdf:resource="{geonet:escapeURI(.//dcat:Dataset[1]/@rdf:about)}"/>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>
          </xsl:if>

          <!-- Always set development status to "production" and life phase to "live" -->
          <mdcat:levensfase>
            <skos:Concept rdf:about="https://data.vlaanderen.be/id/concept/levensfase/live">
              <skos:prefLabel xml:lang="nl">live</skos:prefLabel>
              <skos:prefLabel xml:lang="en">live</skos:prefLabel>
              <skos:prefLabel xml:lang="fr">live</skos:prefLabel>
              <skos:prefLabel xml:lang="de">live</skos:prefLabel>
              <skos:inScheme rdf:resource="https://data.vlaanderen.be/id/conceptscheme/levensfase"/>
            </skos:Concept>
          </mdcat:levensfase>
          <mdcat:ontwikkelingstoestand>
            <skos:Concept rdf:about="https://data.vlaanderen.be/id/concept/ontwikkelingstoestand/PROD">
              <skos:prefLabel xml:lang="nl">productie</skos:prefLabel>
              <skos:prefLabel xml:lang="en">production</skos:prefLabel>
              <skos:prefLabel xml:lang="de">production</skos:prefLabel>
              <skos:prefLabel xml:lang="fr">production</skos:prefLabel>
              <skos:inScheme rdf:resource="https://data.vlaanderen.be/id/conceptscheme/ontwikkelingstoestand"/>
            </skos:Concept>
          </mdcat:ontwikkelingstoestand>
        </xsl:when>

        <!-- Dataset specific -->
        <xsl:when test="$ResourceType = 'dataset' or $ResourceType = 'series'">
          <!-- Reference system information -->
          <xsl:apply-templates select="gmd:referenceSystemInfo"/>

          <!-- Lineage -->
          <xsl:for-each select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement">
            <dct:provenance>
              <dct:ProvenanceStatement>
                <xsl:attribute name="rdf:about" select="concat($MetadataViewUrl, '/formatter/lineage')"/>
                <dct:title xml:lang="{$MetadataLanguage}">
                  <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                </dct:title>
                <xsl:call-template name="LocalisedString">
                  <xsl:with-param name="term">dct:title</xsl:with-param>
                </xsl:call-template>
              </dct:ProvenanceStatement>
            </dct:provenance>
          </xsl:for-each>

          <!-- Maintenance information (tentative) -->
          <xsl:apply-templates select="gmd:identificationInfo/*/gmd:resourceMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode"/>

          <!-- Related services -->
          <xsl:variable name="relatedServices">
            <xsl:if test="$relationLookup">
              <xsl:copy-of select="xslutil:getRelatedServices($RecordUUID)/services/*"/>
            </xsl:if>
          </xsl:variable>

          <xsl:for-each select="$relatedServices/*">
            <xsl:choose>
              <xsl:when test="name() = 'gmd:MD_Metadata'">
                <xsl:variable name="serviceUriPattern" select="xslutil:getUriPattern(gmd:fileIdentifier/gco:CharacterString)"/>
                <dct:relation rdf:resource="{geonet:getResourceURI(., 'service', $serviceUriPattern)}"/>
              </xsl:when>
              <xsl:when test="name() = 'rdf:RDF'">
                <dct:relation rdf:resource="{geonet:escapeURI(.//dcat:DataService[1]/@rdf:about)}"/>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>

          <!-- Spatial representation type -->
          <xsl:apply-templates select="gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode"/>

          <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution">
            <!-- Encoding -->
            <xsl:variable name="Encoding">
              <xsl:apply-templates select="gmd:distributionFormat/gmd:MD_Format/gmd:name/*"/>
            </xsl:variable>

            <!-- Resource locators (access / download URLs) -->
            <xsl:for-each select="gmd:transferOptions/*/gmd:onLine/*">
              <xsl:variable name="Title">
                <xsl:for-each select="gmd:name">
                  <dct:title xml:lang="{$MetadataLanguage}">
                    <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                  </dct:title>
                  <xsl:call-template name="LocalisedString">
                    <xsl:with-param name="term">dct:title</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="gmd:protocol[not(../gmd:name)]">
                  <dct:title xml:lang="{$MetadataLanguage}">
                    <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                  </dct:title>
                  <xsl:call-template name="LocalisedString">
                    <xsl:with-param name="term">dct:title</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:variable>

              <xsl:variable name="LayerName" select="normalize-space(gmd:name[1]/gco:CharacterString)"/>

              <xsl:variable name="Description">
                <xsl:for-each select="gmd:description">
                  <dct:description xml:lang="{$MetadataLanguage}">
                    <xsl:value-of select="concat(normalize-space(gco:CharacterString), ' (De accessURL verwijst naar een gelimiteerde set van data, volgens de INSPIRE afspraken)')"/>
                  </dct:description>
                  <xsl:call-template name="LocalisedString">
                    <xsl:with-param name="term">dct:description</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:variable>

              <xsl:variable name="Protocol" select="gmd:protocol/*/text()"/>

              <xsl:variable name="linkage" select="geonet:escapeURI(gmd:linkage[1]/gmd:URL[1])"/>

              <xsl:variable name="Function" select="gmd:function/gmd:CI_OnLineFunctionCode/@codeListValue"/>

              <xsl:choose>
                <xsl:when test="normalize-space($Function) = ('download', 'offlineAccess', 'order', '')">
                  <xsl:if test="starts-with($Protocol, 'WWW:DOWNLOAD-1.0') or
                                $Protocol = 'LINK download-store' or
                                ends-with($Protocol, 'get-map') or
                                ends-with($Protocol, 'get-tile') or
                                ends-with($Protocol, 'get-feature') or
                                ends-with($Protocol, 'get-coverage')">
                    <xsl:for-each select="$Encoding/dct:format">
                      <dcat:distribution>
                        <dcat:Distribution>
                          <xsl:variable name="distroUUID" select="xslutil:uuidFromString(concat(
                            $Title,
                            $Description,
                            string($linkage),
                            string($LicenseAndRightsConstraints),
                            string(.),
                            string($Protocol),
                            string($Distributors)
                          ))"/>
                          <xsl:variable name="dURI" select="replace(replace($uriPattern, '\{resourceType\}', 'distributions'), '\{resourceUuid\}', $distroUUID)"/>
                          <xsl:if test="$dURI != '' and (starts-with($dURI, 'http://') or starts-with($dURI, 'https://'))">
                            <xsl:attribute name="rdf:about" select="geonet:escapeURI($dURI)"/>
                          </xsl:if>
                          <dct:identifier>
                            <xsl:value-of select="$distroUUID"/>
                          </dct:identifier>
                          <xsl:copy-of select="$Title"/>
                          <xsl:copy-of select="$Description"/>
                          <dcat:accessURL rdf:resource="{$linkage}"/>
                          <xsl:copy-of select="$LicenseAndRightsConstraints"/>
                          <xsl:copy-of select="."/>
                          <dct:conformsTo>
                            <dct:Standard>
                              <xsl:call-template name="Map-protocol">
                                <xsl:with-param name="protocol" select="$Protocol"/>
                              </xsl:call-template>
                              <dct:identifier>
                                <xsl:value-of select="$Protocol"/>
                              </dct:identifier>
                            </dct:Standard>
                          </dct:conformsTo>
                          <xsl:if test="ends-with($Protocol, 'get-map') or
                                        ends-with($Protocol, 'get-tile') or
                                        ends-with($Protocol, 'get-feature') or
                                        ends-with($Protocol, 'get-coverage')">
                            <adms:identifier>
                              <adms:Identifier>
                                <skos:notation>
                                  <xsl:choose>
                                    <xsl:when test="contains($Protocol, 'WMS')"><xsl:attribute name="rdf:datatype" select="'http://www.opengis.net/wms#Layer'"/></xsl:when>
                                    <xsl:when test="contains($Protocol, 'WMTS')"><xsl:attribute name="rdf:datatype" select="'http://schemas.opengis.net/wmts#Layer'"/></xsl:when>
                                    <xsl:when test="contains($Protocol, 'WFS')"><xsl:attribute name="rdf:datatype" select="'http://www.opengis.net/wfs#FeatureType'"/></xsl:when>
                                    <xsl:when test="contains($Protocol, 'WCS')"><xsl:attribute name="rdf:datatype" select="'http://www.opengis.net/wcs#CoverageDescription'"/></xsl:when>
                                  </xsl:choose>
                                  <xsl:value-of select="$LayerName"/>
                                </skos:notation>
                              </adms:Identifier>
                            </adms:identifier>
                          </xsl:if>

                          <xsl:variable name="servedService">
                            <xsl:for-each select="$relatedServices/*">
                              <xsl:if test=".//gmd:onLine//gmd:linkage/gmd:URL[starts-with($linkage, tokenize(., '\?')[1])]">
                                <resourceURI>
                                  <xsl:variable name="serviceUriPattern" select="xslutil:getUriPattern(gmd:fileIdentifier/gco:CharacterString)"/>
                                  <xsl:value-of select="geonet:getResourceURI(., 'service', $serviceUriPattern)"/>
                                </resourceURI>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:variable>

                          <xsl:if test="$servedService/resourceURI">
                            <dcat:accessService rdf:resource="{$servedService/resourceURI[1]}"/>
                          </xsl:if>

                          <xsl:copy-of select="$Distributors"/>
                          <xsl:if test="$ResourceCharacterEncoding != ''">
                            <xsl:copy-of select="$ResourceCharacterEncoding"/>
                          </xsl:if>
                        </dcat:Distribution>
                      </dcat:distribution>
                    </xsl:for-each>
                  </xsl:if>
                </xsl:when>

                <xsl:when test="$Function = ('information', 'search')">
                  <foaf:page rdf:resource="{geonet:escapeURI(.)}"/>
                </xsl:when>

                <xsl:otherwise>
                  <dcat:landingPage rdf:resource="{$linkage}"/>
                </xsl:otherwise>
              </xsl:choose>

            </xsl:for-each>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <!-- Output Catalog record and resource description -->
    <xsl:choose>
      <xsl:when test="$ResourceUri != ''">
        <xsl:choose>
          <xsl:when test="$RecordURI != ''">
            <dcat:CatalogRecord>
              <xsl:if test="normalize-space($RecordURI) != ''">
                <xsl:attribute name="rdf:about" select="$RecordURI"/>
              </xsl:if>
              <foaf:primaryTopic rdf:resource="{$ResourceUri}"/>
              <adms:identifier>
                <adms:Identifier>
                  <skos:notation>
                    <xsl:value-of select="$RecordURI"/>
                  </skos:notation>
                  <vlgen:lokaleIdentificator>
                    <xsl:value-of select="$RecordUUID"/>
                  </vlgen:lokaleIdentificator>
                  <vlgen:naamruimte>
                    <xsl:value-of select="replace($RecordURI, concat('/', $RecordUUID), '')"/>
                  </vlgen:naamruimte>
                  <dct:creator rdf:resoure="https://metadata.vlaanderen.be"/>
                </adms:Identifier>
              </adms:identifier>
              <xsl:copy-of select="$MetadataDescription"/>
            </dcat:CatalogRecord>
          </xsl:when>

          <xsl:otherwise>
            <xsl:if test="normalize-space($MetadataDescription)">
              <dcat:CatalogRecord>
                <foaf:primaryTopic rdf:resource="{$ResourceUri}"/>
                <xsl:copy-of select="$MetadataDescription"/>
              </dcat:CatalogRecord>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:element name="{geonet:getElementName($ResourceDescription)}">
          <xsl:if test="normalize-space($ResourceUri) != ''">
            <xsl:attribute name="rdf:about" select="$ResourceUri"/>
          </xsl:if>
          <adms:identifier>
            <adms:Identifier>
              <skos:notation>
                <xsl:value-of select="$ResourceUri"/>
              </skos:notation>
              <dct:creator rdf:resoure="https://metadata.vlaanderen.be"/>
            </adms:Identifier>
          </adms:identifier>
          <xsl:for-each select="$ResourceDescription/*[name() != 'rdf:type']">
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>

      <xsl:otherwise>
        <xsl:element name="{geonet:getElementName($ResourceDescription)}">
          <xsl:if test="normalize-space($MetadataDescription)">
            <foaf:isPrimaryTopicOf>
              <dcat:CatalogRecord>
                <xsl:copy-of select="$MetadataDescription"/>
              </dcat:CatalogRecord>
            </foaf:isPrimaryTopicOf>
          </xsl:if>
          <xsl:for-each select="$ResourceDescription/*[name() != 'rdf:type']">
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Templates for specific metadata elements
    ========================================
  -->
  <!-- Responsible Organisation -->
  <xsl:template name="ResponsibleOrganisation" match="gmd:CI_ResponsibleParty">
    <xsl:param name="MetadataLanguage"/>
    <xsl:param name="ResourceType"/>

    <xsl:variable name="role" select="gmd:role/gmd:CI_RoleCode/@codeListValue"/>

    <xsl:variable name="IndividualURI" select="geonet:escapeURI(gmd:individualName/*/@xlink:href)"/>

    <xsl:variable name="IndividualName" select="normalize-space(gmd:individualName/*)"/>

    <xsl:variable name="IndividualName-vCard">
      <xsl:for-each select="gmd:individualName">
        <vcard:fn xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(*[self::gco:CharacterString|gmx:Anchor])"/>
        </vcard:fn>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">vcard:fn</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="OrganisationURI" select="geonet:escapeURI(gmd:organisationName/*/@xlink:href)"/>

    <xsl:variable name="URI">
      <xsl:choose>
        <xsl:when test="$IndividualURI != ''">
          <xsl:value-of select="$IndividualURI"/>
        </xsl:when>
        <xsl:when test="$OrganisationURI != ''">
          <xsl:value-of select="$OrganisationURI"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="OrganisationName" select="normalize-space(gmd:organisationName/*)"/>

    <xsl:variable name="OrganisationName-FOAF">
      <xsl:for-each select="gmd:organisationName">
        <foaf:name xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(*[self::gco:CharacterString|gmx:Anchor])"/>
        </foaf:name>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">foaf:name</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="OrganisationName-vCard">
      <xsl:for-each select="gmd:organisationName">
        <vcard:organization-name xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(*[self::gco:CharacterString|gmx:Anchor])"/>
        </vcard:organization-name>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">vcard:organization-name</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="OrganisationNameAsIndividualName-vCard">
      <xsl:for-each select="gmd:organisationName">
        <xsl:variable name="orgName" select="normalize-space(*[self::gco:CharacterString|gmx:Anchor])"/>
        <xsl:if test="$orgName != ''">
          <vcard:fn xml:lang="{$MetadataLanguage}">
            <xsl:value-of select="$orgName"/>
          </vcard:fn>
          <xsl:call-template name="LocalisedString">
            <xsl:with-param name="term">vcard:fn</xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="Email">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/*">
        <xsl:variable name="address" select="geonet:escapeURI(.)"/>
        <xsl:if test="$address != ''">
          <foaf:mbox rdf:resource="mailto:{$address}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="Email-vCard">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/*">
        <xsl:variable name="address" select="geonet:escapeURI(.)"/>
        <xsl:if test="$address != ''">
          <vcard:hasEmail rdf:resource="mailto:{$address}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="URL">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">
        <xsl:variable name="homepage" select="geonet:escapeURI(.)"/>
        <xsl:if test="$homepage != ''">
          <foaf:workplaceHomepage rdf:resource="{$homepage}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="URL-vCard">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">
        <xsl:variable name="url" select="geonet:escapeURI(.)"/>
        <xsl:if test="$url != ''">
          <vcard:hasURL rdf:resource="{$url}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="Telephone">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/*">
        <xsl:variable name="tel" select="translate(translate(translate(translate(translate(normalize-space(.),' ',''),'(',''),')',''),'+',''),'.','')"/>
        <xsl:if test="$tel != ''">
          <foaf:phone rdf:resource="tel:+{$tel}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="Telephone-vCard">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/*">
        <xsl:variable name="tel" select="translate(translate(translate(translate(translate(normalize-space(.),' ',''),'(',''),')',''),'+',''),'.','')"/>
        <xsl:if test="$tel != ''">
          <vcard:hasTelephone rdf:resource="tel:+{$tel}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="Address-vCard">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address">
        <xsl:variable name="deliveryPoint" select="normalize-space(gmd:deliveryPoint/*)"/>
        <xsl:variable name="city" select="normalize-space(gmd:city/*)"/>
        <xsl:variable name="administrativeArea" select="normalize-space(gmd:administrativeArea/*)"/>
        <xsl:variable name="postalCode" select="normalize-space(gmd:postalCode/*)"/>
        <xsl:variable name="country" select="normalize-space(gmd:country/*)"/>
        <xsl:if test="$deliveryPoint != '' or $city != '' or $administrativeArea != '' or $postalCode != '' or $country != ''">
          <locn:address>
            <locn:Address>
              <!--
              <locn:thoroughfare><xsl:value-of select="$deliveryPoint"/></locn:thoroughfare>
              <locn:postName><xsl:value-of select="$city"/></locn:postName>
              <locn:adminUnitL1><xsl:value-of select="$country"/></locn:adminUnitL1>
              -->
              <xsl:if test="$city != ''">
                <adres:gemeentenaam>
                  <xsl:value-of select="$city"/>
                </adres:gemeentenaam>
              </xsl:if>
              <xsl:if test="$administrativeArea != ''">
                <locn:adminUnitL2>
                  <xsl:value-of select="$administrativeArea"/>
                </locn:adminUnitL2>
              </xsl:if>
              <xsl:if test="$country != ''">
                <adres:land>
                  <xsl:value-of select="$country"/>
                </adres:land>
              </xsl:if>
              <xsl:if test="$postalCode != ''">
                <locn:postCode>
                  <xsl:value-of select="$postalCode"/>
                </locn:postCode>
              </xsl:if>
              <locn:fullAddress>
                <xsl:value-of select="concat($deliveryPoint, ' ', $postalCode, ' ', $city, ' ', $country)"/>
              </locn:fullAddress>
            </locn:Address>
          </locn:address>
          <!-- update by GIM: use vcard:Address in addition to locn:Address -->
          <vcard:hasAddress>
            <vcard:Address>
              <xsl:if test="$deliveryPoint != ''">
                <vcard:street-address>
                  <xsl:value-of select="$deliveryPoint"/>
                </vcard:street-address>
              </xsl:if>
              <xsl:if test="$city != ''">
                <vcard:locality>
                  <xsl:value-of select="$city"/>
                </vcard:locality>
              </xsl:if>
              <xsl:if test="$administrativeArea != ''">
                <vcard:region>
                  <xsl:value-of select="$administrativeArea"/>
                </vcard:region>
              </xsl:if>
              <xsl:if test="$postalCode != ''">
                <vcard:postal-code>
                  <xsl:value-of select="$postalCode"/>
                </vcard:postal-code>
              </xsl:if>
              <xsl:if test="$country != ''">
                <vcard:country-name>
                  <xsl:value-of select="$country"/>
                </vcard:country-name>
              </xsl:if>
            </vcard:Address>
          </vcard:hasAddress>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="ROInfo">
      <xsl:variable name="info">
        <xsl:if test="$OrganisationName != ''">
          <xsl:copy-of select="$OrganisationName-FOAF"/>
        </xsl:if>
        <xsl:copy-of select="$Telephone"/>
        <xsl:copy-of select="$Email"/>
        <xsl:copy-of select="$URL"/>
        <xsl:copy-of select="$Address-vCard"/>
      </xsl:variable>

      <foaf:Agent>
        <xsl:choose>
          <xsl:when test="$IndividualURI != ''">
            <xsl:attribute name="rdf:resource" select="$IndividualURI"/>
          </xsl:when>
          <xsl:when test="$OrganisationURI != ''">
            <xsl:attribute name="rdf:resource" select="$OrganisationURI"/>
          </xsl:when>
        </xsl:choose>
        <xsl:copy-of select="$info"/>
      </foaf:Agent>
    </xsl:variable>

    <xsl:variable name="ResponsibleParty">
      <xsl:variable name="info">
        <xsl:if test="$IndividualName != ''">
          <xsl:copy-of select="$IndividualName-vCard"/>
        </xsl:if>
        <xsl:if test="$OrganisationName != ''">
          <xsl:copy-of select="$OrganisationName-vCard"/>
        </xsl:if>
        <xsl:if test="$IndividualName = ''">
          <xsl:copy-of select="$OrganisationNameAsIndividualName-vCard"/>
        </xsl:if>
        <xsl:copy-of select="$Address-vCard"/>
        <xsl:copy-of select="$Email-vCard"/>
        <xsl:copy-of select="$URL-vCard"/>
        <xsl:copy-of select="$Telephone-vCard"/>
      </xsl:variable>

      <vcard:Organization>
        <xsl:choose>
          <xsl:when test="$IndividualURI != ''">
            <xsl:attribute name="rdf:resource" select="$IndividualURI"/>
          </xsl:when>
          <xsl:when test="$OrganisationURI != ''">
            <xsl:attribute name="rdf:resource" select="$OrganisationURI"/>
          </xsl:when>
        </xsl:choose>
        <xsl:copy-of select="$info"/>
      </vcard:Organization>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$ResourceType = 'service'">
        <xsl:choose>
          <xsl:when test="$role = 'pointOfContact'">
            <dcat:contactPoint>
              <xsl:copy-of select="$ResponsibleParty"/>
            </dcat:contactPoint>
          </xsl:when>
          <xsl:when test="$role = 'custodian'">
            <dct:publisher>
              <xsl:copy-of select="$ROInfo"/>
            </dct:publisher>
          </xsl:when>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$role = 'owner'">
            <dct:rightsHolder>
              <xsl:copy-of select="$ROInfo"/>
            </dct:rightsHolder>
          </xsl:when>
          <xsl:when test="$role = 'distributor'">
            <geodcat:distributor>
              <xsl:copy-of select="$ROInfo"/>
            </geodcat:distributor>
          </xsl:when>
          <xsl:when test="$role = 'pointOfContact'">
            <dcat:contactPoint>
              <xsl:copy-of select="$ResponsibleParty"/>
            </dcat:contactPoint>
          </xsl:when>
          <xsl:when test="$role = 'publisher'">
            <dct:publisher>
              <xsl:copy-of select="$ROInfo"/>
            </dct:publisher>
          </xsl:when>
          <xsl:when test="$role = 'author'">
            <dct:creator>
              <xsl:copy-of select="$ROInfo"/>
            </dct:creator>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="$role = 'owner' and count(../../gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue = 'publisher']) = 0">
          <dct:publisher>
            <xsl:copy-of select="$ROInfo"/>
          </dct:publisher>
        </xsl:if>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

  <!-- Conformity -->
  <xsl:template name="Conformity" match="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/gmd:CI_Citation">
    <xsl:param name="MetadataLanguage"/>
    <xsl:if test="../../gmd:pass/gco:Boolean = 'true'">
      <xsl:choose>
        <xsl:when test="../@xlink:href and ../@xlink:href != ''">
          <dct:conformsTo rdf:resource="{geonet:escapeURI(../@xlink:href)}"/>
        </xsl:when>
        <xsl:otherwise>
          <dct:conformsTo>
            <dct:Standard>
              <dct:title xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="geonet:getLabel(gmd:title)"/>
              </dct:title>
            </dct:Standard>
          </dct:conformsTo>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Geographic identifier -->
  <xsl:template name="GeographicIdentifier" match="gmd:EX_GeographicDescription/gmd:geographicIdentifier/*">
    <xsl:param name="MetadataLanguage"/>
    <xsl:variable name="GeoCode">
      <xsl:choose>
        <xsl:when test="gmd:code/gco:CharacterString">
          <xsl:value-of select="gmd:code/gco:CharacterString"/>
        </xsl:when>
        <xsl:when test="gmd:code/gmx:Anchor">
          <xsl:value-of select="gmd:code/gmx:Anchor/@xlink:href"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="GeoURI">
      <xsl:if test="starts-with($GeoCode,'http://') or starts-with($GeoCode,'https://')">
        <xsl:value-of select="geonet:escapeURI($GeoCode)"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="GeoURN">
      <xsl:if test="starts-with($GeoCode,'urn:')">
        <xsl:value-of select="geonet:escapeURI($GeoCode)"/>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$GeoURI != ''">
        <dct:spatial rdf:resource="{$GeoURI}"/>
      </xsl:when>
      <xsl:when test="$GeoCode != ''">
        <dct:spatial>
          <xsl:choose>
            <xsl:when test="$GeoURN != ''">
              <dct:identifier>
                <xsl:value-of select="$GeoURN"/>
              </dct:identifier>
            </xsl:when>
            <xsl:otherwise>
              <skos:prefLabel xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="$GeoCode"/>
              </skos:prefLabel>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:for-each select="gmd:authority/gmd:CI_Citation">
            <skos:inScheme>
              <skos:ConceptScheme>
                <dct:title xml:lang="{$MetadataLanguage}">
                  <xsl:value-of select="gmd:title/gco:CharacterString"/>
                </dct:title>
              </skos:ConceptScheme>
            </skos:inScheme>
          </xsl:for-each>
        </dct:spatial>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Geographic bounding box -->
  <xsl:template name="GeographicBoundingBox" match="gmd:EX_GeographicBoundingBox">
    <xsl:variable name="north" select="gmd:northBoundLatitude/gco:Decimal"/>
    <xsl:variable name="east" select="gmd:eastBoundLongitude/gco:Decimal"/>
    <xsl:variable name="south" select="gmd:southBoundLatitude/gco:Decimal"/>
    <xsl:variable name="west" select="gmd:westBoundLongitude/gco:Decimal"/>

    <!-- Bbox as GML (GeoSPARQL) -->
    <!--  Update by GIM: use polygon encoding for bbox -->
    <xsl:variable name="GMLLiteral">
      <xsl:choose>
        <xsl:when test="$SrsUri = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84'">&lt;gml:Polygon&gt;&lt;gml:exterior&gt;&lt;gml:LinearRing&gt;&lt;gml:posList&gt;<xsl:value-of select="$north"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$east"/>&lt;/gml:posList&gt;&lt;/gml:LinearRing&gt;&lt;/gml:exterior&gt;&lt;/gml:Polygon&gt;</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LonLat'">&lt;gml:Polygon&gt;&lt;gml:exterior&gt;&lt;gml:LinearRing&gt;&lt;gml:posList&gt;<xsl:value-of select="$east"/> <xsl:value-of select="$north"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$west"/> <xsl:value-of select="$south"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$east"/> <xsl:value-of select="$north"/>&lt;/gml:posList&gt;&lt;/gml:LinearRing&gt;&lt;/gml:exterior&gt;&lt;/gml:Polygon&gt;</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LatLon'">&lt;gml:Polygon&gt;&lt;gml:exterior&gt;&lt;gml:LinearRing&gt;&lt;gml:posList&gt;<xsl:value-of select="$north"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$east"/>&lt;/gml:posList&gt;&lt;/gml:LinearRing&gt;&lt;/gml:exterior&gt;&lt;/gml:Polygon&gt;</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <!-- Bbox as WKT (GeoSPARQL) -->

    <xsl:variable name="WKTLiteral">
      <xsl:choose>
        <xsl:when test="$SrsUri = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84'">POLYGON((<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>))</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LonLat'">&lt;<xsl:value-of select="$SrsUri"/>&gt; POLYGON((<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>))</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LatLon'">&lt;<xsl:value-of select="$SrsUri"/>&gt; POLYGON((<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>,<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$east"/>,<xsl:value-of select="$south"/><xsl:text> </xsl:text><xsl:value-of select="$east"/>,<xsl:value-of select="$south"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>,<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>))</xsl:when>
      </xsl:choose>
    </xsl:variable>

    <!-- Bbox as GeoJSON -->

    <xsl:variable name="GeoJSONLiteral">{"type":"Polygon","crs":{"type":"name","properties":{"name":"<xsl:value-of select="$SrsUrn"/>"}},"coordinates":[[[<xsl:value-of select="$west"/><xsl:text>,</xsl:text><xsl:value-of select="$north"/>],[<xsl:value-of select="$east"/><xsl:text>,</xsl:text><xsl:value-of select="$north"/>],[<xsl:value-of select="$east"/><xsl:text>,</xsl:text><xsl:value-of select="$south"/>],[<xsl:value-of select="$west"/><xsl:text>,</xsl:text><xsl:value-of select="$south"/>],[<xsl:value-of select="$west"/><xsl:text>,</xsl:text><xsl:value-of select="$north"/>]]]}</xsl:variable>
    <dct:spatial>
      <!-- Update GIM: put GeoJSON encoding first -->
      <!-- Additional geometry encodings -->
      <!-- Recommended geometry encodings -->
      <dct:Location>
        <locn:geometry>
          <xsl:attribute name="rdf:datatype" select="'https://www.iana.org/assignments/media-types/application/vnd.geo+json'"/>
          <xsl:value-of select="$GeoJSONLiteral"/>
        </locn:geometry>
        <locn:geometry>
          <xsl:attribute name="rdf:datatype" select="'http://www.opengis.net/ont/geosparql#wktLiteral'"/>
          <xsl:value-of select="$WKTLiteral"/>
        </locn:geometry>
        <locn:geometry>
          <xsl:attribute name="rdf:datatype" select="'http://www.opengis.net/ont/geosparql#gmlLiteral'"/>
          <xsl:value-of select="$GMLLiteral"/>
        </locn:geometry>
      </dct:Location>
    </dct:spatial>
  </xsl:template>

  <!-- Temporal extent -->
  <xsl:template name="TemporalExtent" match="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent">
    <xsl:for-each select="gmd:extent/(gml:TimeInstant|gml320:TimeInstant)|gmd:extent/(gml:TimePeriod|gml320:TimePeriod)">
      <xsl:if test="local-name(.) = 'TimeInstant' or ( local-name(.) = 'TimePeriod' and (gml:beginPosition or gml320:beginPosition) and (gml:endPosition or gml320:endPosition) )">
        <xsl:variable name="dateStart">
          <xsl:choose>
            <xsl:when test="local-name(.) = 'TimeInstant'">
              <xsl:value-of select="gml:timePosition|gml320:timePosition"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="gml:beginPosition|gml320:beginPosition"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="dateEnd">
          <xsl:choose>
            <xsl:when test="local-name(.) = 'TimeInstant'">
              <xsl:value-of select="gml:timePosition|gml320:timePosition"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="gml:endPosition|gml320:endPosition"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space($dateStart) != '' or normalize-space($dateEnd) != ''">
          <dct:temporal>
            <dct:PeriodOfTime>
              <xsl:if test="normalize-space($dateStart) != ''">
                <dcat:startDate>
                  <xsl:value-of select="geonet:formatRdfDate($dateStart)"/>
                </dcat:startDate>
              </xsl:if>
              <xsl:if test="normalize-space($dateEnd) != ''">
                <dcat:endDate>
                  <xsl:value-of select="geonet:formatRdfDate($dateEnd)"/>
                </dcat:endDate>
              </xsl:if>
            </dct:PeriodOfTime>
          </dct:temporal>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- Generic date template -->
  <xsl:template name="Dates" match="gmd:date/gmd:CI_Date">
    <xsl:variable name="date" select="geonet:formatRdfDate(gmd:date/*)"/>
    <xsl:variable name="type" select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
    <xsl:choose>
      <xsl:when test="$type = 'publication'">
        <dct:issued>
          <xsl:value-of select="$date"/>
        </dct:issued>
      </xsl:when>
      <xsl:when test="$type = 'revision'">
        <dct:modified>
          <xsl:value-of select="$date"/>
        </dct:modified>
      </xsl:when>
      <xsl:when test="$type = 'creation'">
        <dct:created>
          <xsl:value-of select="$date"/>
        </dct:created>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Keyword -->
  <xsl:template name="Keyword" match="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords">
    <xsl:param name="MetadataLanguage"/>
    <xsl:variable name="OriginatingControlledVocabulary">
      <xsl:for-each select="gmd:thesaurusName/gmd:CI_Citation">
        <xsl:for-each select="gmd:title">
          <dct:title xml:lang="{$MetadataLanguage}">
            <xsl:value-of select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
          </dct:title>
          <xsl:call-template name="LocalisedString">
            <xsl:with-param name="term">dct:title</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="firstThesaurus" select="gmd:thesaurusName/gmd:CI_Citation/gmd:title[1]"/>
    <xsl:variable name="thesaurusIdentifier">
      <xsl:choose>
        <xsl:when test="$firstThesaurus/gmx:Anchor">
          <xsl:value-of select="$firstThesaurus/gmx:Anchor/@xlink:href"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($firstThesaurus/gco:CharacterString)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="scheme">
      <xsl:choose>
        <xsl:when test="normalize-space($firstThesaurus/gco:CharacterString) != ''">
          <xsl:call-template name="GetSchemeFromThesaurusTitle">
            <xsl:with-param name="thesaurusTitle" select="$thesaurusIdentifier"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$thesaurusIdentifier"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:for-each select="gmd:keyword">
      <xsl:variable name="keywordAbout">
        <xsl:choose>
          <xsl:when test="gco:CharacterString">
            <xsl:call-template name="GetAboutFromCharacterString">
              <xsl:with-param name="keyword" select="normalize-space(gco:CharacterString)"/>
              <xsl:with-param name="thesaurusIdentifier" select="$thesaurusIdentifier"/>
              <xsl:with-param name="lang" select="$MetadataLanguage"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="geonet:escapeURI(gmx:Anchor/@xlink:href)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <!-- Keywords not originating from any vocabulary -->
        <xsl:when test="normalize-space($keywordAbout) = ''">
          <xsl:if test="normalize-space(gco:CharacterString|gmx:Anchor) != ''">
            <dcat:keyword xml:lang="{$MetadataLanguage}">
              <xsl:value-of select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
            </dcat:keyword>
          </xsl:if>
          <xsl:call-template name="LocalisedString">
            <xsl:with-param name="term">dcat:keyword</xsl:with-param>
          </xsl:call-template>
        </xsl:when>

        <xsl:when test="$scheme = (
          'http://vocab.belgif.be/auth/datatheme',
          'http://vocab.belgif.be/auth/datatheme/',
          'https://vocab.belgif.be/auth/datatheme',
          'https://vocab.belgif.be/auth/datatheme/'
        )">
          <dcat:theme>
            <skos:Concept>
              <xsl:attribute name="rdf:about" select="geonet:escapeURI($keywordAbout)"/>
              <skos:prefLabel xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
              </skos:prefLabel>
              <xsl:call-template name="LocalisedString">
                <xsl:with-param name="term">skos:prefLabel</xsl:with-param>
              </xsl:call-template>
              <skos:inScheme rdf:resource="http://vocab.belgif.be/auth/datatheme"/>
            </skos:Concept>
          </dcat:theme>
        </xsl:when>

        <xsl:when test="$scheme = (
          'http://inspire.ec.europa.eu/metadata-codelist/TopicCategory',
          'http://inspire.ec.europa.eu/metadata-codelist/TopicCategory/',
          'https://inspire.ec.europa.eu/metadata-codelist/TopicCategory',
          'https://inspire.ec.europa.eu/metadata-codelist/TopicCategory/'
        ) and gmx:Anchor/@xlink:href">

          <xsl:variable name="alreadyAddedGovThemes">
            <xsl:for-each select="../../../gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:thesaurusName/gmd:CI_Citation/gmd:title[1]/gmx:Anchor/@xlink:href = (
            'http://vocab.belgif.be/auth/datatheme',
            'http://vocab.belgif.be/auth/datatheme/',
            'https://vocab.belgif.be/auth/datatheme',
            'https://vocab.belgif.be/auth/datatheme/'
          )]">
              <xsl:for-each select="gmd:keyword/gmx:Anchor">
                <theme>
                  <xsl:value-of select="string(@xlink:href)"/>
                </theme>
              </xsl:for-each>
            </xsl:for-each>

            <xsl:for-each select="preceding-sibling::gmd:keyword">
              <xsl:for-each select="gmx:Anchor">
                <xsl:variable name="precTopic" select="if (starts-with(@xlink:href, 'https'))
                                             then substring-after(@xlink:href, 'https://inspire.ec.europa.eu/metadata-codelist/TopicCategory/')
                                             else substring-after(@xlink:href, 'http://inspire.ec.europa.eu/metadata-codelist/TopicCategory/')"/>
                <xsl:variable name="precTheme">
                  <xsl:call-template name="MapTopicCatToDataGovTheme">
                    <xsl:with-param name="TopicCategory" select="$precTopic"/>
                  </xsl:call-template>
                </xsl:variable>
                <theme>
                  <xsl:value-of select="string($precTheme//skos:Concept/@rdf:about)"/>
                </theme>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:variable>

          <xsl:variable name="topic" select="if (starts-with(gmx:Anchor/@xlink:href, 'https'))
                                           then substring-after(gmx:Anchor/@xlink:href, 'https://inspire.ec.europa.eu/metadata-codelist/TopicCategory/')
                                           else substring-after(gmx:Anchor/@xlink:href, 'http://inspire.ec.europa.eu/metadata-codelist/TopicCategory/')"/>
          <xsl:variable name="theme">
            <xsl:call-template name="MapTopicCatToDataGovTheme">
              <xsl:with-param name="TopicCategory" select="$topic"/>
            </xsl:call-template>
          </xsl:variable>

          <xsl:if test="count($alreadyAddedGovThemes/theme[. = $theme/dcat:theme/skos:Concept/@rdf:about]) = 0">
            <xsl:copy-of select="$theme"/>
          </xsl:if>
        </xsl:when>

        <!-- Default to a dct:subject -->
        <xsl:otherwise>
          <dct:subject>
            <skos:Concept>
              <xsl:attribute name="rdf:about" select="geonet:escapeURI($keywordAbout)"/>
              <skos:prefLabel xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
              </skos:prefLabel>
              <xsl:call-template name="LocalisedString">
                <xsl:with-param name="term">skos:prefLabel</xsl:with-param>
              </xsl:call-template>
              <skos:inScheme>
                <xsl:choose>
                  <xsl:when test="normalize-space($scheme) != ''">
                    <xsl:attribute name="rdf:resource" select="normalize-space($scheme)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <skos:ConceptScheme>
                      <xsl:copy-of select="$OriginatingControlledVocabulary"/>
                    </skos:ConceptScheme>
                  </xsl:otherwise>
                </xsl:choose>
              </skos:inScheme>
            </skos:Concept>
          </dct:subject>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- Alternate title -->
  <xsl:template name="AlternateTitle" match="gmd:alternateTitle">
    <xsl:param name="MetadataLanguage"/>
    <xsl:if test="normalize-space(gco:CharacterString|gmx:Anchor) != ''">
      <dcat:keyword xml:lang="{if ($MetadataLanguage != '') then $MetadataLanguage else 'nl'}">
        <xsl:value-of select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
      </dcat:keyword>
    </xsl:if>
  </xsl:template>

  <!-- Conforms to - Feature catalog description -->
  <xsl:template name="FeatureCatalogueDescription" match="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription">
    <dct:conformsTo>
      <dct:Standard>
        <xsl:variable name="uuidref" select="gmd:featureCatalogueCitation/@uuidref"/>
        <xsl:choose>
          <xsl:when test="normalize-space(gmd:featureCatalogueCitation/@xlink:href) != ''">
            <xsl:attribute name="rdf:about" select="gmd:featureCatalogueCitation/@xlink:href"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="rdf:about" select="concat(
              $catalogUrl,
              '/csw?service=CSW&amp;request=GetRecordById&amp;version=2.0.2&amp;outputSchema=http://www.isotc211.org/2005/gmd&amp;elementSetName=full&amp;id=',
              $uuidref
            )"/>
          </xsl:otherwise>
        </xsl:choose>
        <dct:identifier>
          <xsl:value-of select="$uuidref"/>
        </dct:identifier>

        <xsl:variable name="title" select="geonet:getLabel(gmd:featureCatalogueCitation/gmd:CI_Citation/gmd:title)"/>
        <xsl:if test="$title != ''">
          <dct:title>
            <xsl:value-of select="$title"/>
          </dct:title>
        </xsl:if>
        <xsl:apply-templates select="gmd:featureCatalogueCitation/gmd:CI_Citation/gmd:edition"/>
        <dct:type rdf:resource="https://www.iso.org/standard/39965.html"/>
      </dct:Standard>
    </dct:conformsTo>
  </xsl:template>

  <!--
  <xsl:template name="ContentInfo" match="gmd:contentInfo">
    <xsl:choose>
      <xsl:when test="name(*) = 'gmd:MD_CoverageDescription'"></xsl:when>
      <xsl:when test="name(*) = 'gmd:MD_ImageDescription'"></xsl:when>
      <xsl:when test="name(*) = 'gmd:AbstractMD_ContentInformation'"></xsl:when>
      <xsl:when test="name(*) = 'gmd:MD_RangeDimension'"></xsl:when>
      <xsl:when test="name(*) = 'gmd:MD_Band'"></xsl:when>
      <xsl:when test="name(*) = 'gmd:MD_CoverageContentTypeCode'"></xsl:when>
      <xsl:when test="name(*) = 'gmd:MD_ImagingConditionCode'"></xsl:when>
    </xsl:choose>
  </xsl:template>
  -->

  <!-- Reference system info -->
  <xsl:template name="ReferenceSystemInfo" match="gmd:referenceSystemInfo">
    <xsl:variable name="code" select="gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code"/>
    <xsl:variable name="crs" select="string($code/gmx:Anchor/@xlink:href|$code/gco:CharacterString)"/>

    <xsl:choose>
      <xsl:when test="starts-with($crs, 'http://') or starts-with($crs, 'https://')">
        <dct:conformsTo>
          <dct:Standard>
            <xsl:attribute name="rdf:about" select="$crs"/>
            <dct:type rdf:resource="http://inspire.ec.europa.eu/glossary/SpatialReferenceSystem"/>
          </dct:Standard>
        </dct:conformsTo>
      </xsl:when>
      <xsl:otherwise>
        <dct:conformsTo>
          <dct:Standard>
            <dct:identifier>
              <xsl:value-of select="$crs"/>
            </dct:identifier>
            <dct:type rdf:resource="http://inspire.ec.europa.eu/glossary/SpatialReferenceSystem"/>
          </dct:Standard>
        </dct:conformsTo>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Topic category -->
  <xsl:template name="TopicCategory" match="gmd:identificationInfo/*/gmd:topicCategory">
    <xsl:variable name="TopicCategory" select="normalize-space(gmd:MD_TopicCategoryCode)"/>
    <xsl:variable name="DataGovTheme">
      <xsl:call-template name="MapTopicCatToDataGovTheme">
        <xsl:with-param name="TopicCategory" select="$TopicCategory"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$DataGovTheme/dcat:theme">

        <xsl:variable name="alreadyAddedGovThemes">
          <xsl:for-each select="../gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:thesaurusName/gmd:CI_Citation/gmd:title[1]/gmx:Anchor/@xlink:href = (
            'http://vocab.belgif.be/auth/datatheme',
            'http://vocab.belgif.be/auth/datatheme/',
            'https://vocab.belgif.be/auth/datatheme',
            'https://vocab.belgif.be/auth/datatheme/'
          )]">
            <xsl:for-each select="gmd:keyword/gmx:Anchor">
              <theme>
                <xsl:value-of select="string(@xlink:href)"/>
              </theme>
            </xsl:for-each>
          </xsl:for-each>

          <xsl:for-each select="../gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:thesaurusName/gmd:CI_Citation/gmd:title[1]/gmx:Anchor/@xlink:href = (
            'http://inspire.ec.europa.eu/metadata-codelist/TopicCategory',
            'http://inspire.ec.europa.eu/metadata-codelist/TopicCategory/',
            'https://inspire.ec.europa.eu/metadata-codelist/TopicCategory',
            'https://inspire.ec.europa.eu/metadata-codelist/TopicCategory/'
          )]">
            <xsl:for-each select="gmd:keyword/gmx:Anchor">
              <xsl:variable name="topic" select="if (starts-with(@xlink:href, 'https'))
                                             then substring-after(@xlink:href, 'https://inspire.ec.europa.eu/metadata-codelist/TopicCategory/')
                                             else substring-after(@xlink:href, 'http://inspire.ec.europa.eu/metadata-codelist/TopicCategory/')"/>
              <xsl:variable name="theme">
                <xsl:call-template name="MapTopicCatToDataGovTheme">
                  <xsl:with-param name="TopicCategory" select="$topic"/>
                </xsl:call-template>
              </xsl:variable>
              <theme>
                <xsl:value-of select="string($theme//skos:Concept/@rdf:about)"/>
              </theme>
            </xsl:for-each>
          </xsl:for-each>

          <xsl:for-each select="preceding-sibling::gmd:topicCategory">
            <xsl:variable name="mapped">
              <xsl:call-template name="MapTopicCatToDataGovTheme">
                <xsl:with-param name="TopicCategory" select="normalize-space(gmd:MD_TopicCategoryCode)"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$mapped/dcat:theme">
              <theme>
                <xsl:value-of select="string($mapped/dcat:theme/skos:Concept/@rdf:about)"/>
              </theme>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:if test="count($alreadyAddedGovThemes/theme[. = $DataGovTheme/dcat:theme/skos:Concept/@rdf:about]) = 0">
          <xsl:copy-of select="$DataGovTheme"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$TopicCategory != ''">
        <dct:subject rdf:resource="{$TopicCategoryCodelistUri}/{$TopicCategory}"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Character encoding -->
  <xsl:template name="CharacterEncoding" match="gmd:characterSet/gmd:MD_CharacterSetCode">
    <xsl:variable name="CharSetCode">
      <xsl:choose>
        <xsl:when test="@codeListValue = 'ucs2'">
          <xsl:text>ISO-10646-UCS-2</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'ucs4'">
          <xsl:text>ISO-10646-UCS-4</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'utf7'">
          <xsl:text>UTF-7</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'utf8'">
          <xsl:text>UTF-8</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'utf16'">
          <xsl:text>UTF-16</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part1'">
          <xsl:text>ISO-8859-1</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part2'">
          <xsl:text>ISO-8859-2</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part3'">
          <xsl:text>ISO-8859-3</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part4'">
          <xsl:text>ISO-8859-4</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part5'">
          <xsl:text>ISO-8859-5</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part6'">
          <xsl:text>ISO-8859-6</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part7'">
          <xsl:text>ISO-8859-7</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part8'">
          <xsl:text>ISO-8859-8</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part9'">
          <xsl:text>ISO-8859-9</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part10'">
          <xsl:text>ISO-8859-10</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part11'">
          <xsl:text>ISO-8859-11</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part12'">
          <xsl:text>ISO-8859-12</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part13'">
          <xsl:text>ISO-8859-13</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part14'">
          <xsl:text>ISO-8859-14</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part15'">
          <xsl:text>ISO-8859-15</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = '8859part16'">
          <xsl:text>ISO-8859-16</xsl:text>
        </xsl:when>
        <!-- Mapping to be verified: multiple candidates are available in the IANA register for jis -->
        <xsl:when test="@codeListValue = 'jis'">
          <xsl:text>JIS_Encoding</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'shiftJIS'">
          <xsl:text>Shift_JIS</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'eucJP'">
          <xsl:text>EUC-JP</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'usAscii'">
          <xsl:text>US-ASCII</xsl:text>
        </xsl:when>
        <!-- Mapping to be verified: multiple candidates are available in the IANA register ebcdic  -->
        <xsl:when test="@codeListValue = 'ebcdic'">
          <xsl:text>IBM037</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'eucKR'">
          <xsl:text>EUC-KR</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'big5'">
          <xsl:text>Big5</xsl:text>
        </xsl:when>
        <xsl:when test="@codeListValue = 'GB2312'">
          <xsl:text>GB2312</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <cnt:characterEncoding>
      <xsl:value-of select="$CharSetCode"/>
    </cnt:characterEncoding>
  </xsl:template>

  <!-- Encoding -->
  <xsl:template name="Encoding" match="gmd:distributionFormat/gmd:MD_Format/gmd:name/*">
    <xsl:choose>
      <xsl:when test="@xlink:href and @xlink:href != ''">
        <dct:format rdf:resource="{geonet:escapeURI(@xlink:href)}"/>
      </xsl:when>
      <xsl:otherwise>
        <dct:format>
          <skos:Concept>
            <rdf:type rdf:resource="http://purl.org/dc/terms/MediaTypeOrExtent"/>
            <skos:prefLabel>
              <xsl:value-of select="."/>
            </skos:prefLabel>
          </skos:Concept>
        </dct:format>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Maintenance information -->
  <xsl:template name="MaintenanceInformation" match="gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode">
    <!-- The following parameter maps frequency codes used in ISO 19139 metadata to the corresponding ones of the Dublin Core Collection Description Frequency Vocabulary (when available). -->
    <xsl:variable name="FrequencyCodeURI">
      <xsl:if test="@codeListValue != ''">
        <xsl:choose>
          <xsl:when test="@codeListValue = 'continual'">
            <xsl:value-of select="concat($opfq,'CONT')"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'daily'">
            <xsl:value-of select="concat($opfq,'DAILY')"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'weekly'">
            <xsl:value-of select="concat($opfq,'WEEKLY')"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'fortnightly'">
            <xsl:value-of select="concat($opfq,'BIWEEKLY')"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'monthly'">
            <xsl:value-of select="concat($opfq,'MONTHLY')"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'quarterly'">
            <xsl:value-of select="concat($opfq,'QUARTERLY')"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'biannually'">
            <xsl:value-of select="concat($opfq,'ANNUAL_2')"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'annually'">
            <xsl:value-of select="concat($opfq,'ANNUAL')"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'asNeeded'">
            <!--  A mapping is missing in Dublin Core and MDR Freq NAL-->
            <xsl:value-of select="concat($MaintenanceFrequencyCodelistUri,'/',@codeListValue)"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'irregular'">
            <xsl:value-of select="concat($opfq,'IRREG')"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'notPlanned'">
            <!--  A mapping is missing in Dublin Core and MDR Freq NAL -->
            <xsl:value-of select="concat($MaintenanceFrequencyCodelistUri,'/',@codeListValue)"/>
          </xsl:when>
          <xsl:when test="@codeListValue = 'unknown'">
            <!--  A mapping is missing in Dublin Core -->
            <xsl:value-of select="concat($opfq,'UNKNOWN')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$FrequencyCodeURI != ''">
      <dct:accrualPeriodicity rdf:resource="{geonet:escapeURI($FrequencyCodeURI)}"/>
    </xsl:if>
  </xsl:template>

  <!-- Spatial representation type (tentative) -->
  <xsl:template name="SpatialRepresentationType" match="gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode">
    <adms:representationTechnique>
      <skos:Concept rdf:about="{$SpatialRepresentationTypeCodelistUri}/{@codeListValue}">
        <skos:notation>
          <xsl:value-of select="'het primaire ruimtelijke voorstellingstype waarin de data in de dataset wordt beheercfl'"/>
        </skos:notation>
        <skos:inScheme rdf:resource="{$SpatialRepresentationTypeCodelistUri}"/>
      </skos:Concept>
    </adms:representationTechnique>
  </xsl:template>

  <!-- Spatial resolution -->
  <xsl:template name="SpatialResolution" match="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution">
    <xsl:choose>
      <xsl:when test="gmd:distance/gco:Distance[@uom = 'm']">
        <dcat:spatialResolutionInMeters>
          <xsl:value-of select="string(gmd:distance/gco:Distance)"/>
        </dcat:spatialResolutionInMeters>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Version info -->
  <xsl:template name="VersionInfo" match="gmd:edition">
    <xsl:variable name="label" select="normalize-space(geonet:getLabel(.))"/>
    <xsl:if test="$label != ''">
      <owl:versionInfo>
        <xsl:value-of select="$label"/>
      </owl:versionInfo>
    </xsl:if>
  </xsl:template>

  <!-- Multilingual text -->
  <xsl:template name="LocalisedString">
    <xsl:param name="term"/>
    <xsl:for-each select="gmd:PT_FreeText/*/gmd:LocalisedCharacterString">
      <xsl:variable name="value" select="normalize-space(.)"/>
      <xsl:variable name="langs">
        <xsl:call-template name="Alpha3-to-Alpha2">
          <xsl:with-param name="lang" select="translate(translate(@locale, $uppercase, $lowercase), '#', '')"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$value != ''">
        <xsl:element name="{$term}">
          <xsl:attribute name="xml:lang">
            <xsl:value-of select="$langs"/>
          </xsl:attribute>
          <xsl:value-of select="$value"/>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="geonet:formatRdfDate">
    <xsl:param name="date"/>

    <xsl:variable name="dateType" select="if (matches($date, '^\d{4}-\d{2}-\d{2}Z|(-|\+)\d{2}:\d{2}|T\d{2}:\d{2}:\d{2}(\.\d+)?(Z|(-|\+)\d{2}:\d{2})?$'))
                                          then 'dateTime'
                                          else 'date'"/>
    <xsl:choose>
      <xsl:when test="normalize-space($date) = ''">
        <xsl:value-of select="''"/>
      </xsl:when>
      <xsl:when test="$dateType = 'date'">
        <xsl:value-of select="format-date($date, '[Y0001]-[M01]-[D01]')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="timeZone">
          <xsl:choose>
            <xsl:when test="$dateType = 'dateTime' and normalize-space(format-dateTime($date, '[Z]')) != ''">
              <xsl:value-of select="normalize-space(format-dateTime($date, '[Z]')) != ''"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'+01:00'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat(format-dateTime($date, '[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]'), $timeZone)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
