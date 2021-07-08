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

<xsl:stylesheet xmlns:adms   = "http://www.w3.org/ns/adms#"
                xmlns:cnt    = "http://www.w3.org/2011/content#"
                xmlns:dc     = "http://purl.org/dc/elements/1.1/"
                xmlns:dcat   = "http://www.w3.org/ns/dcat#"
                xmlns:dct    = "http://purl.org/dc/terms/"
                xmlns:dctype = "http://purl.org/dc/dcmitype/"
                xmlns:earl   = "http://www.w3.org/ns/earl#"
                xmlns:foaf   = "http://xmlns.com/foaf/0.1/"
                xmlns:gco    = "http://www.isotc211.org/2005/gco"
                xmlns:gmd    = "http://www.isotc211.org/2005/gmd"
                xmlns:gml    = "http://www.opengis.net/gml/3.2"
                xmlns:gml320 = "http://www.opengis.net/gml"
                xmlns:gmx    = "http://www.isotc211.org/2005/gmx"
                xmlns:gsp    = "http://www.opengis.net/ont/geosparql#"
                xmlns:i      = "http://inspire.ec.europa.eu/schemas/common/1.0"
                xmlns:i-gp   = "http://inspire.ec.europa.eu/schemas/geoportal/1.0"
                xmlns:locn   = "http://www.w3.org/ns/locn#"
                xmlns:owl    = "http://www.w3.org/2002/07/owl#"
                xmlns:org    = "http://www.w3.org/ns/org#"
                xmlns:prov   = "http://www.w3.org/ns/prov#"
                xmlns:rdf    = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs   = "http://www.w3.org/2000/01/rdf-schema#"
                xmlns:schema = "http://schema.org/"
                xmlns:skos   = "http://www.w3.org/2004/02/skos/core#"
                xmlns:srv    = "http://www.isotc211.org/2005/srv"
                xmlns:vcard  = "http://www.w3.org/2006/vcard/ns#"
                xmlns:wdrs   = "http://www.w3.org/2007/05/powder-s#"
                xmlns:xlink  = "http://www.w3.org/1999/xlink"
                xmlns:xsi    = "http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsl    = "http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet = "http://www.fao.org/geonetwork"
                xmlns:xs     = "http://www.w3.org/2001/XMLSchema"
                xmlns:uuid="java:java.util.UUID"
                exclude-result-prefixes="earl gco gmd gml gmx i i-gp srv xlink xsi xsl wdrs cnt dctype owl dc gml320 xs prov gsp org uuid"
                version="2.0">

  <xsl:output method="xml"
              indent="yes"
              encoding="utf-8"
              cdata-section-elements="locn:geometry" />

  <xsl:include href="../convert/keyword_CharacterString_to_Anchor.xsl"/>

  <!--
    The current specifications for the core and extended GeoDCAT-AP profiles are available on the Joinup collaboration platform:
    https://joinup.ec.europa.eu/node/139283/
  -->

  <!--
    Parameter $CoupledResourceLookUp
    This parameter specifies whether the coupled resource, referenced via @xlink:href, should be looked up to fetch the resource's  unique resource identifier (i.e., code and code space). More precisely:
    - value "enabled": The coupled resource is looked up
    - value "disabled": The coupled resource is not looked up

    CAVEAT: Using this feature may cause the transformation to hang, in case the URL in @xlink:href is broken, the request hangs indefinitely, or does not return the expected resource (e.g., and HTML page, instead of an XML-encoded ISO 19139 record). It is strongly recommended that this issue is dealt with by using appropriate configuration parameters and error handling (e.g., by specifying a timeout on HTTP calls and by setting the HTTP Accept header to "application/xml").
  -->

  <xsl:param name="CoupledResourceLookUp" select="'disabled'"/>

  <!--
    Global parameters
    =======================
  -->

  <!-- Variables to be used to convert strings into lower/uppercase by using the translate() function. -->
  <xsl:variable name="lowercase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="uppercase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <!-- URIs, URNs and names for spatial reference system registers. -->
  <xsl:param name="EpsgSrsBaseUri">http://www.opengis.net/def/crs/EPSG/0</xsl:param>
  <xsl:param name="EpsgSrsBaseUrn">urn:ogc:def:crs:EPSG</xsl:param>
  <xsl:param name="EpsgSrsName">EPSG Coordinate Reference Systems</xsl:param>
  <xsl:param name="OgcSrsBaseUri">http://www.opengis.net/def/crs/OGC</xsl:param>
  <xsl:param name="OgcSrsBaseUrn">urn:ogc:def:crs:OGC</xsl:param>
  <xsl:param name="OgcSrsName">OGC Coordinate Reference Systems</xsl:param>

  <!-- URI and URN for CRS84. -->
  <xsl:param name="Crs84Uri" select="concat($OgcSrsBaseUri,'/1.3/CRS84')"/>
  <xsl:param name="Crs84Urn" select="concat($OgcSrsBaseUrn,':1.3:CRS84')"/>

  <!-- URI and URN for ETRS89. -->
  <xsl:param name="Etrs89Uri" select="concat($EpsgSrsBaseUri,'/4258')"/>
  <xsl:param name="Etrs89Urn" select="concat($EpsgSrsBaseUrn,'::4258')"/>

  <!-- URI and URN of the spatial reference system (SRS) used in the bounding box.
       The default SRS is CRS84. If a different SRS is used, also parameter
       $SrsAxisOrder must be specified. -->

  <!-- The SRS URI is used in the WKT and GML encodings of the bounding box. -->
  <xsl:param name="SrsUri" select="$Crs84Uri"/>
  <!-- The SRS URN is used in the GeoJSON encoding of the bounding box. -->
  <xsl:param name="SrsUrn" select="$Crs84Urn"/>

  <!-- Axis order for the reference SRS:
       - "LonLat": longitude / latitude
       - "LatLon": latitude / longitude.
       The axis order must be specified only if the reference SRS is different from CRS84.
       If the reference SRS is CRS84, this parameter is ignored. -->
  <xsl:param name="SrsAxisOrder">LonLat</xsl:param>

  <!-- Namespaces -->
  <xsl:param name="xsd">http://www.w3.org/2001/XMLSchema#</xsl:param>
  <xsl:param name="dct">http://purl.org/dc/terms/</xsl:param>
  <xsl:param name="dctype">http://purl.org/dc/dcmitype/</xsl:param>
  <xsl:param name="dcat">http://www.w3.org/ns/dcat#</xsl:param>
  <xsl:param name="gsp">http://www.opengis.net/ont/geosparql#</xsl:param>
  <xsl:param name="foaf">http://xmlns.com/foaf/0.1/</xsl:param>
  <xsl:param name="vcard">http://www.w3.org/2006/vcard/ns#</xsl:param>
  <xsl:param name="op">http://publications.europa.eu/resource/authority/</xsl:param>
  <xsl:param name="opcountry" select="concat($op,'country/')"/>
  <xsl:param name="oplang" select="concat($op,'language/')"/>
  <xsl:param name="opcb" select="concat($op,'corporate-body/')"/>
  <xsl:param name="opfq" select="concat($op,'frequency/')"/>
  <xsl:param name="cldFrequency">http://purl.org/cld/freq/</xsl:param>
  <!-- This is used as the datatype for the GeoJSON-based encoding of the bounding box. -->
  <xsl:param name="geojsonMediaTypeUri">https://www.iana.org/assignments/media-types/application/vnd.geo+json</xsl:param>

  <!-- INSPIRE code list URIs -->
  <xsl:param name="INSPIRECodelistUri">http://inspire.ec.europa.eu/metadata-codelist/</xsl:param>
  <xsl:param name="SpatialDataServiceCategoryCodelistUri" select="concat($INSPIRECodelistUri,'SpatialDataServiceCategory')"/>
  <xsl:param name="DegreeOfConformityCodelistUri" select="concat($INSPIRECodelistUri,'DegreeOfConformity')"/>
  <xsl:param name="ResourceTypeCodelistUri" select="concat($INSPIRECodelistUri,'ResourceType')"/>
  <xsl:param name="ResponsiblePartyRoleCodelistUri" select="concat($INSPIRECodelistUri,'ResponsiblePartyRole')"/>
  <xsl:param name="SpatialDataServiceTypeCodelistUri" select="concat($INSPIRECodelistUri,'SpatialDataServiceType')"/>
  <xsl:param name="TopicCategoryCodelistUri" select="concat($INSPIRECodelistUri,'TopicCategory')"/>

  <!-- INSPIRE code list URIs (not yet supported; the URI pattern is tentative) -->
  <xsl:param name="SpatialRepresentationTypeCodelistUri" select="concat($INSPIRECodelistUri,'SpatialRepresentationTypeCode')"/>
  <xsl:param name="MaintenanceFrequencyCodelistUri" select="concat($INSPIRECodelistUri,'MaintenanceFrequencyCode')"/>

  <!-- INSPIRE glossary URI -->
  <xsl:param name="INSPIREGlossaryUri">http://inspire.ec.europa.eu/glossary/</xsl:param>

  <!-- GIM custom variables -->
  <xsl:variable name="catalogUrl" select="concat(substring-before($resourcePrefix, '/resource'), '/dut')"/>

  <!--
    Metadata template
    =================
   -->
  <xsl:template match="gmd:MD_Metadata|//gmd:MD_Metadata" mode="to-dcat">
    <xsl:param name="MetadataViewUrl">
      <xsl:value-of select="concat($catalogUrl, '/catalog.search#/metadata/', gmd:fileIdentifier/gco:CharacterString)"/>
    </xsl:param>

    <!-- Metadata language: corresponding Alpha-2 codes -->
    <xsl:param name="ormlang">
      <xsl:choose>
        <xsl:when test="gmd:language/gmd:LanguageCode/@codeListValue != ''">
          <xsl:value-of select="translate(gmd:language/gmd:LanguageCode/@codeListValue, $uppercase, $lowercase)"/>
        </xsl:when>
        <xsl:when test="gmd:language/gmd:LanguageCode != ''">
          <xsl:value-of select="translate(gmd:language/gmd:LanguageCode, $uppercase, $lowercase)"/>
        </xsl:when>
        <xsl:when test="gmd:language/gco:CharacterString != ''">
          <xsl:value-of select="translate(gmd:language/gco:CharacterString, $uppercase, $lowercase)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>

    <xsl:param name="MetadataLanguage">
      <xsl:call-template name="Alpha3-to-Alpha2">
        <xsl:with-param name="lang" select="$ormlang"/>
      </xsl:call-template>
    </xsl:param>

    <!-- Resource language: corresponding Alpha-2 codes -->
    <xsl:param name="orrlang">
      <xsl:variable name="langElem">
        <xsl:choose>
          <xsl:when test="gmd:language">
            <xsl:value-of select="gmd:language"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="gmd:identificationInfo/*/gmd:language[1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$langElem/gmd:LanguageCode/@codeListValue != ''">
          <xsl:value-of select="translate($langElem/gmd:LanguageCode/@codeListValue,$uppercase,$lowercase)"/>
        </xsl:when>
        <xsl:when test="$langElem/gmd:LanguageCode != ''">
          <xsl:value-of select="translate($langElem/gmd:LanguageCode,$uppercase,$lowercase)"/>
        </xsl:when>
        <xsl:when test="$langElem/gco:CharacterString != ''">
          <xsl:value-of select="translate($langElem/gco:CharacterString,$uppercase,$lowercase)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>

    <xsl:param name="IsoScopeCode">
      <xsl:value-of select="normalize-space(gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)"/>
    </xsl:param>

    <xsl:param name="ResourceType">
      <xsl:choose>
        <xsl:when test="$IsoScopeCode = 'dataset' or $IsoScopeCode = 'nonGeographicDataset'">
          <xsl:text>dataset</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$IsoScopeCode"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:param name="ServiceType">
      <xsl:value-of select="gmd:identificationInfo/*/srv:serviceType/gco:LocalName"/>
    </xsl:param>

    <xsl:param name="ResourceTitle">
      <xsl:for-each select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:title">
        <dct:title xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(gco:CharacterString)"/>
        </dct:title>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">dct:title</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="ResourceAbstract">
      <xsl:for-each select="gmd:identificationInfo[1]/*/gmd:abstract">
        <dct:description xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(gco:CharacterString)"/>
        </dct:description>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">dct:description</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="Lineage">
      <xsl:for-each select="gmd:dataQualityInfo/*/gmd:lineage/*/gmd:statement">
        <dct:provenance>
          <dct:ProvenanceStatement>
            <rdfs:label xml:lang="{$MetadataLanguage}">
              <xsl:value-of select="normalize-space(gco:CharacterString)"/>
            </rdfs:label>
            <xsl:call-template name="LocalisedString">
              <xsl:with-param name="term">rdfs:label</xsl:with-param>
            </xsl:call-template>
          </dct:ProvenanceStatement>
        </dct:provenance>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="MetadataDate">
      <xsl:choose>
        <xsl:when test="gmd:dateStamp/gco:Date">
          <xsl:value-of select="gmd:dateStamp/gco:Date"/>
        </xsl:when>
        <xsl:when test="gmd:dateStamp/gco:DateTime">
          <xsl:value-of select="substring(gmd:dateStamp/gco:DateTime/text(),1,10)"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>

    <xsl:param name="uuidRegex" select="'([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}){1}'"/>

    <xsl:param name="UniqueResourceIdentifier">
      <xsl:for-each select="gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*">
        <xsl:choose>
          <xsl:when test="gmd:codeSpace/gco:CharacterString/text() != ''">
            <xsl:value-of select="concat(gmd:codeSpace/gco:CharacterString/text(), gmd:code/gco:CharacterString/text())"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="gmd:code/gco:CharacterString/text()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="RecordUUID" select="string(gmd:fileIdentifier/gco:CharacterString)"/>

    <xsl:param name="ResourceUUID">
      <xsl:choose>
        <xsl:when test="$UniqueResourceIdentifier[matches(., $uuidRegex)][1]">
          <xsl:value-of select="$UniqueResourceIdentifier[matches(., $uuidRegex)][1]"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- This should not happen -->
          <xsl:value-of select="uuid:toString(uuid:randomUUID())"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <xsl:param name="MetadataUri">
      <xsl:variable name="mURI" select="concat($resourcePrefix,'/records/', $RecordUUID)"/>
      <xsl:if test="$mURI != '' and (starts-with($mURI, 'http://') or starts-with($mURI, 'https://'))">
        <xsl:value-of select="geonet:escapeURI($mURI)"/>
      </xsl:if>
    </xsl:param>

    <xsl:param name="ResourceUri">
      <xsl:variable name="rURI" select="concat($resourcePrefix, '/', $ResourceType, '/', $ResourceUUID)"/>
      <xsl:if test="$rURI != '' and (starts-with($rURI, 'http://') or starts-with($rURI, 'https://'))">
        <xsl:value-of select="geonet:escapeURI($rURI)"/>
      </xsl:if>
    </xsl:param>

    <xsl:param name="ConstraintsRelatedToAccessAndUse">
      <xsl:variable name="licensesConstraintsAnchor" select="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:otherConstraints[../gmd:useConstraints or ../gmd:accessConstraints]/gmx:Anchor|
                                                             gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:useLimitation/gmx:Anchor"/>
      <xsl:variable name="licensesConstraintsCharacterString" select="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:otherConstraints[../gmd:useConstraints or ../gmd:accessConstraints]/gco:CharacterString|
                                                                      gmd:identificationInfo[1]/*/gmd:resourceConstraints/*/gmd:useLimitation/gco:CharacterString"/>

      <xsl:variable name="modelLicencieKeywords">
        <license>
          <url>https://data.vlaanderen.be/doc/licentie/modellicentie-gratis-hergebruik/v1.0</url>
          <keyword>modellicentie-gratis-hergebruik</keyword>
          <keyword>modellicentie_gratis_hergebruik</keyword>
        </license>
        <license>
          <url>http://data.vlaanderen.be/id/licentie/onvoorwaardelijk-hergebruik/v1.0</url>
          <keyword>onvoorwaardelijk-hergebruik</keyword>
          <keyword>onvoorwaardelijk_hergebruik</keyword>
        </license>
        <license>
          <url>https://data.vlaanderen.be/id/licentie/modellicentie-hergebruik-tegen-vergoeding/v1.0</url>
          <keyword>modellicentie-hergebruik-tegen-vergoeding</keyword>
          <keyword>modellicentie_hergebruik_tegen_vergoeding</keyword>
        </license>
        <license>
          <url>https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0</url>
          <keyword>creative-commons-zero-verklaring</keyword>
          <keyword>creative_commons_zero_verklaring</keyword>
          <keyword>cc0</keyword>
        </license>
      </xsl:variable>

      <xsl:variable name="modelLicencie">
        <xsl:for-each select="$licensesConstraintsAnchor">
          <xsl:variable name="currentUrl" select="translate(@xlink:href, $uppercase, $lowercase)"/>
          <xsl:for-each select="$modelLicencieKeywords/license/keyword">
            <xsl:if test="contains($currentUrl, string())">
              <license>
                <xsl:value-of select="string(../url)"/>
              </license>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$modelLicencie and normalize-space($modelLicencie) != ''">
          <xsl:element name="dct:license">
            <xsl:attribute name="rdf:resource" select="geonet:escapeURI($modelLicencie/license[1])"/>
          </xsl:element>
        </xsl:when>
        <xsl:when test="$licensesConstraintsCharacterString[contains(., 'Gratis Open Data licentie')]">
          <xsl:element name="dct:license">
            <xsl:attribute name="rdf:resource" select="'http://overheid.vlaanderen.be/hergebruik/licenties/v1-0/html/modellicentie-gratis-hergebruik'"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="dct:license">
            <xsl:attribute name="rdf:resource" select="geonet:escapeURI($MetadataViewUrl)"/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <!-- Metadata description (metadata on metadata) -->
    <xsl:param name="MetadataDescription">
      <dct:identifier>
        <xsl:value-of select="$RecordUUID"/>
      </dct:identifier>

      <xsl:if test="$ormlang != ''">
        <xsl:variable name="languageConcept">
          <xsl:call-template name="Map-language">
            <xsl:with-param name="lang" select="translate($ormlang, $lowercase, $uppercase)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="normalize-space($languageConcept) != ''">
            <dct:language>
              <xsl:copy-of select="$languageConcept"/>
            </dct:language>
          </xsl:when>
          <xsl:otherwise>
            <dct:language rdf:resource="{geonet:escapeURI(concat($oplang, translate($ormlang, $lowercase, $uppercase)))}"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="$MetadataDate != ''">
        <dct:modified>
          <xsl:value-of select="$MetadataDate"/>
        </dct:modified>
      </xsl:if>

      <dct:conformsTo>
        <dct:Standard rdf:about="https://inspire.ec.europa.eu/documents/geodcat-ap">
          <dct:title>GeoDCAT-AP</dct:title>
          <dct:description>GeoDCAT-AP is an extension to the “DCAT application profile for European data portals” (DCAT-AP) for the representation of geographic metadata.</dct:description>
        </dct:Standard>
      </dct:conformsTo>
    </xsl:param>

    <!-- Resource description (resource metadata) -->
    <xsl:param name="ResourceDescription">
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

      <!-- Unique Resource Identifier -->
      <dct:identifier>
        <xsl:value-of select="$ResourceUUID"/>
      </dct:identifier>
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*[concat(gmd:codeSpace/gco:CharacterString, gmd:code/gco:CharacterString) != $ResourceUUID]"/>

      <xsl:copy-of select="$ResourceTitle"/>

      <xsl:copy-of select="$ResourceAbstract"/>

      <!-- Maintenance information (tentative) -->
      <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceMaintenance">
        <xsl:apply-templates select="gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode"/>
      </xsl:for-each>
      <!-- Topic category -->

      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:topicCategory">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <!-- Keyword -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
        <xsl:with-param name="ResourceType" select="$ResourceType"/>
        <xsl:with-param name="ServiceType" select="$ServiceType"/>
      </xsl:apply-templates>

      <!-- Coupled resources -->
      <xsl:apply-templates select="gmd:identificationInfo[1]/*/srv:operatesOn">
        <xsl:with-param name="ResourceType" select="$ResourceType"/>
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <!-- Resource Language -->
      <xsl:if test="$orrlang != ''">
        <xsl:variable name="languageConcept">
          <xsl:call-template name="Map-language">
            <xsl:with-param name="lang" select="translate($ormlang, $lowercase, $uppercase)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="normalize-space($languageConcept) != ''">
            <dct:language>
              <xsl:copy-of select="$languageConcept"/>
            </dct:language>
          </xsl:when>
          <xsl:otherwise>
            <dct:language rdf:resource="{geonet:escapeURI(concat($oplang, translate($ormlang, $lowercase, $uppercase)))}"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <!-- Spatial extend -->
      <xsl:apply-templates select="gmd:identificationInfo[1]/*/*[self::gmd:extent|self::srv:extent]/*/gmd:geographicElement">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <!-- Temporal extent -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"/>

      <!-- Creation date, publication date, date of last revision -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation"/>

      <!-- Lineage -->
      <xsl:if test="$ResourceType != 'service' and $Lineage != ''">
        <xsl:copy-of select="$Lineage"/>
      </xsl:if>

      <!-- Conformity -->
      <xsl:apply-templates select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/gmd:CI_Citation">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <xsl:choose>
        <xsl:when test="$ResourceType = 'service'">
          <xsl:copy-of select="$ConstraintsRelatedToAccessAndUse"/>
        </xsl:when>
        <!-- Distributions -->
        <xsl:when test="$ResourceType = 'dataset' or $ResourceType = 'series'">
          <!-- Spatial representation type -->
          <xsl:variable name="SpatialRepresentationType">
            <xsl:apply-templates select="gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode"/>
          </xsl:variable>
          <xsl:for-each select="gmd:distributionInfo/gmd:MD_Distribution">
            <!-- Encoding -->
            <xsl:variable name="Encoding">
              <xsl:apply-templates select="gmd:distributionFormat/gmd:MD_Format/gmd:name/*"/>
            </xsl:variable>
            <!-- Resource locators (access / download URLs) -->
            <xsl:for-each select="gmd:transferOptions/*/gmd:onLine/*[not(gmd:function/gmd:CI_OnLineFunctionCode/@codeListValue = ('information'))]">
              <xsl:variable name="Title">
                <xsl:for-each select="gmd:name">
                  <dct:title xml:lang="{$MetadataLanguage}">
                    <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                  </dct:title>
                  <xsl:call-template name="LocalisedString">
                    <xsl:with-param name="term">dct:title</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
                <!-- Update by GIM: also include the protocol as a possible second title, but only in case there is no gmd:name.  -->
                <xsl:for-each select="gmd:protocol[not(../gmd:name)]">
                  <dct:title xml:lang="{$MetadataLanguage}">
                    <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                  </dct:title>
                  <xsl:call-template name="LocalisedString">
                    <xsl:with-param name="term">dct:title</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:variable>
              <xsl:variable name="Description">
                <xsl:for-each select="gmd:description">
                  <dct:description xml:lang="{$MetadataLanguage}">
                    <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                  </dct:description>
                  <xsl:call-template name="LocalisedString">
                    <xsl:with-param name="term">dct:description</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:variable>
              <xsl:variable name="TitleAndDescription">
                <xsl:copy-of select="$Title"/>
                <xsl:copy-of select="$Description"/>
              </xsl:variable>
              <xsl:variable name="Protocol" select="gmd:protocol/*/text()"/>

              <xsl:variable name="linkage" select="gmd:linkage"/>

              <xsl:choose>
                <xsl:when test="starts-with($Protocol, 'WWW:DOWNLOAD-1.0') or $Protocol = 'LINK download-store'">
                  <xsl:for-each select="$Encoding/dct:format">
                    <dcat:distribution>
                      <dcat:Distribution>
                        <!-- Title and description -->
                        <xsl:copy-of select="$TitleAndDescription"/>
                        <!-- Access URL -->
                        <xsl:for-each select="$linkage/gmd:URL">
                          <dcat:accessURL rdf:resource="{geonet:escapeURI(.)}"/>
                        </xsl:for-each>
                        <!-- Constraints related to access and use -->
                        <xsl:copy-of select="$ConstraintsRelatedToAccessAndUse"/>
                        <!-- Spatial representation type (tentative) -->
                        <xsl:copy-of select="$SpatialRepresentationType"/>
                        <!-- Encoding -->
                        <xsl:copy-of select="."/>

                        <!-- Conform to standard -->
                        <dct:conformsTo>
                          <dct:Standard>
                            <dct:title>
                              <xsl:value-of select="$Protocol"/>
                            </dct:title>
                          </dct:Standard>
                        </dct:conformsTo>
                      </dcat:Distribution>
                    </dcat:distribution>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="format">
                    <xsl:call-template name="Map-format">
                      <xsl:with-param name="protocol" select="$Protocol"/>
                      <xsl:with-param name="url" select="$linkage/gmd:URL[1]"/>
                    </xsl:call-template>
                  </xsl:variable>

                  <dcat:distribution>
                    <dcat:Distribution>
                      <!-- Title and description -->
                      <xsl:copy-of select="$TitleAndDescription"/>
                      <!-- Access URL -->
                      <xsl:for-each select="$linkage/gmd:URL">
                        <dcat:accessURL rdf:resource="{geonet:escapeURI(.)}"/>
                      </xsl:for-each>
                      <!-- Constraints related to access and use -->
                      <xsl:copy-of select="$ConstraintsRelatedToAccessAndUse"/>
                      <!-- Spatial representation type (tentative) -->
                      <xsl:copy-of select="$SpatialRepresentationType"/>
                      <!-- Encoding -->
                      <xsl:if test="$format != ''">
                        <dct:format>
                          <skos:prefLabel>
                            <xsl:value-of select="$format"/>
                          </skos:prefLabel>
                          <rdfs:label>
                            <xsl:value-of select="$format"/>
                          </rdfs:label>
                        </dct:format>
                      </xsl:if>
                      <!-- Conform to standard -->
                      <dct:conformsTo>
                        <dct:Standard>
                          <dct:title>
                            <xsl:value-of select="$Protocol"/>
                          </dct:title>
                        </dct:Standard>
                      </dct:conformsTo>
                    </dcat:Distribution>
                  </dcat:distribution>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <!-- Responsible organisation -->
      <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'][1]|
                            gmd:identificationInfo/*/gmd:pointOfContact[gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner'][1]">
        <xsl:apply-templates select="gmd:CI_ResponsibleParty">
          <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
          <xsl:with-param name="ResourceType" select="$ResourceType"/>
        </xsl:apply-templates>
      </xsl:for-each>
      <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact[not(gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode/@codeListValue = ('publisher', 'owner'))]">
        <xsl:apply-templates select="gmd:CI_ResponsibleParty">
          <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
          <xsl:with-param name="ResourceType" select="$ResourceType"/>
        </xsl:apply-templates>
      </xsl:for-each>

      <dct:relation rdf:resource="{geonet:escapeURI($MetadataViewUrl)}"/>

      <xsl:copy-of select="$ConstraintsRelatedToAccessAndUse"/>

      <xsl:if test="gmd:identificationInfo/*/gmd:resourceConstraints/*/gmd:otherConstraints/gmx:Anchor/@xlink:href =
                      ('http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations',
                       'https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations')">
        <dct:accessRights>
          <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/access-right/PUBLIC">
            <rdf:type rdf:resource="http://purl.org/dc/terms/RightsStatement"/>
            <skos:prefLabel xml:lang="nl">publiek</skos:prefLabel>
            <skos:prefLabel xml:lang="en">public</skos:prefLabel>
            <skos:prefLabel xml:lang="fr">public</skos:prefLabel>
            <skos:prefLabel xml:lang="de">public</skos:prefLabel>
            <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/access-right"/>
          </skos:Concept>
        </dct:accessRights>
      </xsl:if>
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$ResourceUri != ''">
        <xsl:choose>
          <xsl:when test="$MetadataUri != ''">
            <dcat:CatalogRecord>
              <xsl:if test="normalize-space($MetadataUri) != ''">
                <xsl:attribute name="rdf:about" select="$MetadataUri"/>
              </xsl:if>
              <foaf:primaryTopic rdf:resource="{$ResourceUri}"/>
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
          <xsl:call-template name="withoutType">
            <xsl:with-param name="description" select="$ResourceDescription"/>
          </xsl:call-template>
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
          <xsl:call-template name="withoutType">
            <xsl:with-param name="description" select="$ResourceDescription"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Templates for specific metadata elements
    ========================================
  -->

  <!-- Unique Resource Identifier -->
  <xsl:template name="UniqueResourceIdentifier" match="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*">
    <xsl:param name="ns">
      <xsl:value-of select="gmd:codeSpace/gco:CharacterString"/>
    </xsl:param>

    <xsl:param name="code">
      <xsl:value-of select="gmd:code/gco:CharacterString"/>
    </xsl:param>

    <xsl:param name="id">
      <xsl:choose>
        <xsl:when test="$ns != ''">
          <xsl:choose>
            <xsl:when test="substring($ns,string-length($ns),1) = '/'">
              <xsl:value-of select="concat($ns,$code)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat($ns,'/',$code)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$code"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>

    <dct:identifier>
      <xsl:value-of select="$id"/>
    </dct:identifier>
  </xsl:template>

  <!-- Responsible Organisation -->
  <xsl:template name="ResponsibleOrganisation" match="gmd:CI_ResponsibleParty">
    <xsl:param name="MetadataLanguage"/>

    <xsl:param name="role">
      <xsl:value-of select="gmd:role/gmd:CI_RoleCode/@codeListValue"/>
    </xsl:param>

    <xsl:param name="IndividualURI">
      <xsl:value-of select="geonet:escapeURI(gmd:individualName/*/@xlink:href)"/>
    </xsl:param>

    <xsl:param name="IndividualName">
      <xsl:value-of select="normalize-space(gmd:individualName/*)"/>
    </xsl:param>

    <xsl:param name="IndividualName-FOAF">
      <xsl:for-each select="gmd:individualName">
        <foaf:name xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(*[self::gco:CharacterString|gmx:Anchor])"/>
        </foaf:name>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">foaf:name</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="IndividualName-vCard">
      <xsl:for-each select="gmd:individualName">
        <vcard:fn xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(*[self::gco:CharacterString|gmx:Anchor])"/>
        </vcard:fn>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">vcard:fn</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="OrganisationURI">
      <xsl:value-of select="geonet:escapeURI(gmd:organisationName/*/@xlink:href)"/>
    </xsl:param>

    <xsl:param name="URI">
      <xsl:choose>
        <xsl:when test="$IndividualURI != ''">
          <xsl:value-of select="$IndividualURI"/>
        </xsl:when>
        <xsl:when test="$OrganisationURI != ''">
          <xsl:value-of select="$OrganisationURI"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>

    <xsl:param name="OrganisationName">
      <xsl:value-of select="normalize-space(gmd:organisationName/*)"/>
    </xsl:param>

    <xsl:param name="OrganisationName-FOAF">
      <xsl:for-each select="gmd:organisationName">
        <foaf:name xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(*[self::gco:CharacterString|gmx:Anchor])"/>
        </foaf:name>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">foaf:name</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="OrganisationName-vCard">
      <xsl:for-each select="gmd:organisationName">
        <vcard:organization-name xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(*[self::gco:CharacterString|gmx:Anchor])"/>
        </vcard:organization-name>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">vcard:organization-name</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="OrganisationNameAsIndividualName-vCard">
      <xsl:for-each select="gmd:organisationName">
        <vcard:fn xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="normalize-space(*[self::gco:CharacterString|gmx:Anchor])"/>
        </vcard:fn>
        <xsl:call-template name="LocalisedString">
          <xsl:with-param name="term">vcard:fn</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="Email">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/*">
        <foaf:mbox rdf:resource="mailto:{geonet:escapeURI(.)}"/>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="Email-vCard">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/*">
        <vcard:hasEmail rdf:resource="mailto:{geonet:escapeURI(.)}"/>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="URL">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">
        <foaf:workplaceHomepage rdf:resource="{geonet:escapeURI(.)}"/>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="URL-vCard">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">
        <vcard:hasURL rdf:resource="{geonet:escapeURI(.)}"/>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="Telephone">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/*">
        <foaf:phone rdf:resource="tel:+{translate(translate(translate(translate(translate(normalize-space(.),' ',''),'(',''),')',''),'+',''),'.','')}"/>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="Telephone-vCard">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/*">
        <vcard:hasTelephone rdf:resource="tel:+{translate(translate(translate(translate(translate(normalize-space(.),' ',''),'(',''),')',''),'+',''),'.','')}"/>
      </xsl:for-each>
    </xsl:param>

    <xsl:param name="Address">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address">
        <xsl:variable name="deliveryPoint" select="normalize-space(gmd:deliveryPoint/*)"/>
        <xsl:variable name="city" select="normalize-space(gmd:city/*)"/>
        <xsl:variable name="administrativeArea" select="normalize-space(gmd:administrativeArea/*)"/>
        <xsl:variable name="postalCode" select="normalize-space(gmd:postalCode/*)"/>
        <xsl:variable name="country" select="normalize-space(gmd:country/*)"/>
        <xsl:if test="$deliveryPoint != '' or $city != '' or $administrativeArea != '' or $postalCode != '' or $country != ''">
          <locn:address>
            <locn:Address>
              <xsl:if test="$deliveryPoint != ''">
                <locn:thoroughfare>
                  <xsl:value-of select="$deliveryPoint"/>
                </locn:thoroughfare>
              </xsl:if>
              <xsl:if test="$city != ''">
                <locn:postName>
                  <xsl:value-of select="$city"/>
                </locn:postName>
              </xsl:if>
              <xsl:if test="$administrativeArea != ''">
                <locn:adminUnitL2>
                  <xsl:value-of select="$administrativeArea"/>
                </locn:adminUnitL2>
              </xsl:if>
              <xsl:if test="$postalCode != ''">
                <locn:postCode>
                  <xsl:value-of select="$postalCode"/>
                </locn:postCode>
              </xsl:if>
              <xsl:if test="$country != ''">
                <locn:adminUnitL1>
                  <xsl:value-of select="$country"/>
                </locn:adminUnitL1>
              </xsl:if>
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
                <vcard:locality>
                  <xsl:value-of select="$administrativeArea"/>
                </vcard:locality>
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
    </xsl:param>

    <xsl:param name="Address-vCard">
      <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address">
        <xsl:variable name="deliveryPoint" select="normalize-space(gmd:deliveryPoint/*)"/>
        <xsl:variable name="city" select="normalize-space(gmd:city/*)"/>
        <xsl:variable name="administrativeArea" select="normalize-space(gmd:administrativeArea/*)"/>
        <xsl:variable name="postalCode" select="normalize-space(gmd:postalCode/*)"/>
        <xsl:variable name="country" select="normalize-space(gmd:country/*)"/>
        <xsl:if test="$deliveryPoint != '' or $city != '' or $administrativeArea != '' or $postalCode != '' or $country != ''">
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
    </xsl:param>

    <xsl:param name="ROInfo">
      <xsl:variable name="info">
        <xsl:if test="$IndividualName != ''">
          <xsl:copy-of select="$IndividualName-FOAF"/>
        </xsl:if>
        <xsl:if test="$IndividualName = '' and $OrganisationName != ''">
          <xsl:copy-of select="$OrganisationName-FOAF"/>
        </xsl:if>
        <xsl:copy-of select="$Telephone"/>
        <xsl:copy-of select="$Email"/>
        <xsl:copy-of select="$URL"/>
        <xsl:copy-of select="$Address"/>
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

    </xsl:param>
    <xsl:param name="ResponsibleParty">
      <xsl:variable name="info">
        <xsl:if test="$IndividualName != ''">
          <xsl:copy-of select="$IndividualName-vCard"/>
        </xsl:if>
        <xsl:if test="$IndividualName != '' and $OrganisationName != ''">
          <xsl:copy-of select="$OrganisationName-vCard"/>
        </xsl:if>
        <xsl:if test="$IndividualName = '' and $OrganisationName != ''">
          <xsl:copy-of select="$OrganisationNameAsIndividualName-vCard"/>
        </xsl:if>
        <xsl:copy-of select="$Telephone-vCard"/>
        <xsl:copy-of select="$Email-vCard"/>
        <xsl:copy-of select="$URL-vCard"/>
        <xsl:copy-of select="$Address-vCard"/>
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
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$role = 'owner'">
        <dct:rightsHolder>
          <xsl:copy-of select="$ROInfo"/>
        </dct:rightsHolder>
      </xsl:when>
      <xsl:when test="$role = 'pointOfContact'">
        <dcat:contactPoint>
          <xsl:copy-of select="$ResponsibleParty"/>
        </dcat:contactPoint>
      </xsl:when>
      <xsl:when test="($role = 'publisher') or ($role = 'owner' and count(../../gmd:pointOfContact/gmd:CI_ResponsibleParty/gmd:role/gmd:CI_RoleCode[@codeListValue = 'publisher']) = 0)">
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
  </xsl:template>

  <xsl:template name="ResourceLocator" match="gmd:transferOptions/*/gmd:onLine/*/gmd:linkage">
    <xsl:param name="MetadataLanguage"/>
    <xsl:param name="ResourceType"/>
    <xsl:choose>
      <xsl:when test="$ResourceType = 'dataset' or $ResourceType = 'series'">
        <dct:title xml:lang="{$MetadataLanguage}">
          <xsl:value-of select="../gmd:description/gco:CharacterString"/>
        </dct:title>
        <dcat:accessURL rdf:resource="{geonet:escapeURI(gmd:URL)}"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Coupled resource -->
  <xsl:template name="CoupledResource" match="gmd:identificationInfo[1]/*/srv:operatesOn">
    <xsl:param name="href" select="@xlink:href"/>
    <xsl:param name="code">
      <xsl:choose>
        <xsl:when test="$CoupledResourceLookUp = 'enabled' and $href != '' and (starts-with($href, 'http://') or starts-with($href, 'https://'))">
          <xsl:value-of select="document($href)//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString"/>
        </xsl:when>
        <xsl:when test="*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString != ''">
          <xsl:value-of select="*/gmd:citation/*/gmd:identifier/*/gmd:code/gco:CharacterString"/>
        </xsl:when>
        <xsl:when test="@uuidref != ''">
          <xsl:value-of select="@uuidref"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="codespace">
      <xsl:choose>
        <xsl:when test="$CoupledResourceLookUp = 'enabled' and $href != '' and (starts-with($href, 'http://') or starts-with($href, 'https://'))">
          <xsl:value-of select="document($href)//gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace/gco:CharacterString"/>
        </xsl:when>
        <xsl:when test="*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace/gco:CharacterString != ''">
          <xsl:value-of select="*/gmd:citation/*/gmd:identifier/*/gmd:codeSpace/gco:CharacterString"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="resID" select="concat($codespace, $code)"/>
    <xsl:param name="uriref" select="@uriref"/>

    <!-- The use of @uriref is still under discussion by the INSPIRE MIG. -->
    <xsl:choose>
      <xsl:when test="$uriref != ''">
        <dct:hasPart rdf:resource="{geonet:escapeURI(@uriref)}"/>
      </xsl:when>
      <xsl:when test="$code != ''">
        <xsl:choose>
          <xsl:when test="starts-with($code, 'http://') or starts-with($code, 'https://')">
            <dct:hasPart rdf:resource="{geonet:escapeURI($code)}"/>
          </xsl:when>
          <xsl:otherwise>
            <dct:hasPart>
              <xsl:choose>
                <xsl:when test="starts-with($resID, 'http://') or starts-with($resID, 'https://')">
                  <dct:identifier>
                    <xsl:value-of select="$resID"/>
                  </dct:identifier>
                </xsl:when>
                <xsl:otherwise>
                  <dct:identifier>
                    <xsl:value-of select="$resID"/>
                  </dct:identifier>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="$href != '' and $href != '' and (starts-with($href, 'http://') or starts-with($href, 'https://'))">
                <foaf:isPrimaryTopicOf>
                  <dcat:CatalogRecord rdf:about="{geonet:escapeURI($href)}"/>
                </foaf:isPrimaryTopicOf>
              </xsl:if>
            </dct:hasPart>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Conformity -->
  <xsl:template name="Conformity" match="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/gmd:CI_Citation">
    <xsl:param name="MetadataLanguage"/>
    <xsl:variable name="specinfo">
      <dct:title xml:lang="{$MetadataLanguage}">
        <xsl:value-of select="geonet:getLabel(gmd:title)"/>
      </dct:title>
      <xsl:apply-templates select="gmd:date/gmd:CI_Date"/>
    </xsl:variable>
    <xsl:if test="../../gmd:pass/gco:Boolean = 'true'">
      <xsl:choose>
        <xsl:when test="../@xlink:href and ../@xlink:href != ''">
          <dct:conformsTo rdf:resource="{geonet:escapeURI(../@xlink:href)}"/>
        </xsl:when>
        <xsl:otherwise>
          <dct:conformsTo>
            <dct:Standard>
              <xsl:copy-of select="$specinfo"/>
            </dct:Standard>
          </dct:conformsTo>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Geographic extent -->
  <xsl:template name="GeographicExtent" match="gmd:identificationInfo[1]/*/*[self::gmd:extent|self::srv:extent]/*/gmd:geographicElement">
    <xsl:param name="MetadataLanguage"/>

    <xsl:apply-templates select="gmd:EX_GeographicDescription/gmd:geographicIdentifier/*">
      <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="gmd:EX_GeographicBoundingBox"/>
  </xsl:template>

  <!-- Geographic identifier -->
  <xsl:template name="GeographicIdentifier" match="gmd:EX_GeographicDescription/gmd:geographicIdentifier/*">
    <xsl:param name="MetadataLanguage"/>
    <xsl:param name="GeoCode">
      <xsl:choose>
        <xsl:when test="gmd:code/gco:CharacterString">
          <xsl:value-of select="gmd:code/gco:CharacterString"/>
        </xsl:when>
        <xsl:when test="gmd:code/gmx:Anchor">
          <xsl:value-of select="gmd:code/gmx:Anchor/@xlink:href"/>
        </xsl:when>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="GeoURI">
      <xsl:if test="starts-with($GeoCode,'http://') or starts-with($GeoCode,'https://')">
        <xsl:value-of select="geonet:escapeURI($GeoCode)"/>
      </xsl:if>
    </xsl:param>
    <xsl:param name="GeoURN">
      <xsl:if test="starts-with($GeoCode,'urn:')">
        <xsl:value-of select="geonet:escapeURI($GeoCode)"/>
      </xsl:if>
    </xsl:param>

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
                <xsl:apply-templates select="gmd:date/gmd:CI_Date"/>
              </skos:ConceptScheme>
            </skos:inScheme>
          </xsl:for-each>
        </dct:spatial>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Geographic bounding box -->
  <xsl:template name="GeographicBoundingBox" match="gmd:EX_GeographicBoundingBox">
    <xsl:param name="north" select="gmd:northBoundLatitude/gco:Decimal"/>
    <xsl:param name="east" select="gmd:eastBoundLongitude/gco:Decimal"/>
    <xsl:param name="south" select="gmd:southBoundLatitude/gco:Decimal"/>
    <xsl:param name="west" select="gmd:westBoundLongitude/gco:Decimal"/>

    <!-- Bbox as GML (GeoSPARQL) -->
    <!--  Update by GIM: use polygon encoding for bbox -->
    <xsl:param name="GMLLiteral-Polygon">
      <xsl:choose>
        <xsl:when test="$SrsUri = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84'">&lt;gml:Polygon&gt;&lt;gml:exterior&gt;&lt;gml:LinearRing&gt;&lt;gml:posList&gt;<xsl:value-of select="$north"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$east"/>&lt;/gml:posList&gt;&lt;/gml:LinearRing&gt;&lt;/gml:exterior&gt;&lt;/gml:Polygon&gt;</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LonLat'">&lt;gml:Polygon&gt;&lt;gml:exterior&gt;&lt;gml:LinearRing&gt;&lt;gml:posList&gt;<xsl:value-of select="$east"/> <xsl:value-of select="$north"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$west"/> <xsl:value-of select="$south"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$east"/> <xsl:value-of select="$north"/>&lt;/gml:posList&gt;&lt;/gml:LinearRing&gt;&lt;/gml:exterior&gt;&lt;/gml:Polygon&gt;</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LatLon'">&lt;gml:Polygon&gt;&lt;gml:exterior&gt;&lt;gml:LinearRing&gt;&lt;gml:posList&gt;<xsl:value-of select="$north"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$east"/> <xsl:value-of select="$south"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$west"/> <xsl:value-of select="$north"/> <xsl:value-of select="$east"/>&lt;/gml:posList&gt;&lt;/gml:LinearRing&gt;&lt;/gml:exterior&gt;&lt;/gml:Polygon&gt;</xsl:when>
      </xsl:choose>
    </xsl:param>

    <!-- Bbox as WKT (GeoSPARQL) -->

    <xsl:param name="WKTLiteral">
      <xsl:choose>
        <xsl:when test="$SrsUri = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84'">POLYGON((<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>))</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LonLat'">&lt;<xsl:value-of select="$SrsUri"/>&gt; POLYGON((<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>,<xsl:value-of select="$east"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$south"/>,<xsl:value-of select="$west"/><xsl:text> </xsl:text><xsl:value-of select="$north"/>))</xsl:when>
        <xsl:when test="$SrsAxisOrder = 'LatLon'">&lt;<xsl:value-of select="$SrsUri"/>&gt; POLYGON((<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>,<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$east"/>,<xsl:value-of select="$south"/><xsl:text> </xsl:text><xsl:value-of select="$east"/>,<xsl:value-of select="$south"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>,<xsl:value-of select="$north"/><xsl:text> </xsl:text><xsl:value-of select="$west"/>))</xsl:when>
      </xsl:choose>
    </xsl:param>

    <!-- Bbox as GeoJSON -->

    <xsl:param name="GeoJSONLiteral">{"type":"Polygon","crs":{"type":"name","properties":{"name":"<xsl:value-of select="$SrsUrn"/>"}},"coordinates":[[[<xsl:value-of select="$west"/><xsl:text>,</xsl:text><xsl:value-of select="$north"/>],[<xsl:value-of select="$east"/><xsl:text>,</xsl:text><xsl:value-of select="$north"/>],[<xsl:value-of select="$east"/><xsl:text>,</xsl:text><xsl:value-of select="$south"/>],[<xsl:value-of select="$west"/><xsl:text>,</xsl:text><xsl:value-of select="$south"/>],[<xsl:value-of select="$west"/><xsl:text>,</xsl:text><xsl:value-of select="$north"/>]]]}</xsl:param>
    <dct:spatial>
      <!-- Update GIM: put GeoJSON encoding first -->
      <!-- Additional geometry encodings -->
      <!-- Recommended geometry encodings -->
      <dct:Location>
        <locn:geometry>
          <xsl:value-of select="$GeoJSONLiteral"/>
        </locn:geometry>
        <locn:geometry>
          <xsl:value-of select="$WKTLiteral"/>
        </locn:geometry>
        <locn:geometry>
          <xsl:value-of select="$GMLLiteral-Polygon"/>
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
        <dct:temporal>
          <dct:PeriodOfTime>
            <schema:startDate>
              <xsl:value-of select="$dateStart"/>
            </schema:startDate>
            <schema:endDate>
              <xsl:value-of select="$dateEnd"/>
            </schema:endDate>
          </dct:PeriodOfTime>
        </dct:temporal>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- Dates of publication, last revision, creation -->
  <xsl:template name="ResourceDates" match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation">
    <xsl:apply-templates select="gmd:date/gmd:CI_Date"/>
  </xsl:template>

  <!-- Generic date template -->
  <xsl:template name="Dates" match="gmd:date/gmd:CI_Date">
    <xsl:param name="date">
      <xsl:value-of select="gmd:date/gco:Date"/>
    </xsl:param>
    <xsl:param name="type">
      <xsl:value-of select="gmd:dateType/gmd:CI_DateTypeCode/@codeListValue"/>
    </xsl:param>
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

  <!-- Constraints related to access and use -->
  <xsl:template name="ConstraintsRelatedToAccesAndUse" match="gmd:identificationInfo[1]/*/gmd:resourceConstraints/*">
    <xsl:param name="MetadataLanguage"/>

    <!-- Mapping added for compliance with the 2017 edition of the INSPIRE Metadata Technical Guidelines -->
    <xsl:for-each select="gmd:otherConstraints[../gmd:useConstraints]">
      <xsl:choose>
        <!-- In case the rights/licence URL IS NOT provided -->
        <xsl:when test="normalize-space(gco:CharacterString) != ''">
          <dct:license>
            <dct:LicenseDocument>
              <rdfs:label xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="normalize-space(gco:CharacterString)"/>
              </rdfs:label>
              <xsl:call-template name="LocalisedString">
                <xsl:with-param name="term">rdfs:label</xsl:with-param>
              </xsl:call-template>
            </dct:LicenseDocument>
          </dct:license>
        </xsl:when>
        <xsl:when test="gmd:MD_RestrictionCode">
          <xsl:variable name="use-constraints-code" select="normalize-space(@codeListValue)"/>
          <xsl:variable name="use-constraints-text">
            <xsl:choose>
              <xsl:when test="normalize-space(.) != ''">
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:when>
              <xsl:when test="$use-constraints-code != ''">
                <xsl:value-of select="$use-constraints-code"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <dct:license>
            <dct:LicenseDocument>
              <xsl:if test="$use-constraints-code != ''">
                <dct:identifier>
                  <xsl:value-of select="$use-constraints-code"/>
                </dct:identifier>
              </xsl:if>
              <rdfs:label xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="$use-constraints-text"/>
              </rdfs:label>
              <xsl:call-template name="LocalisedString">
                <xsl:with-param name="term">rdfs:label</xsl:with-param>
              </xsl:call-template>
            </dct:LicenseDocument>
          </dct:license>
        </xsl:when>
        <!-- In case the rights/licence URL IS provided -->
        <xsl:when test="gmx:Anchor/@xlink:href">
          <dct:license rdf:resource="{geonet:escapeURI(gmx:Anchor/@xlink:href)}"/>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>

    <!-- Mapping revised for compliance with the 2017 edition of the INSPIRE Metadata Technical Guidelines -->
    <xsl:for-each select="gmd:otherConstraints[../gmd:accessConstraints]">
      <xsl:choose>
        <xsl:when test="normalize-space(gco:CharacterString) != ''">
          <dct:accessRights>
            <dct:RightsStatement>
              <rdfs:label xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="normalize-space(gco:CharacterString)"/>
              </rdfs:label>
              <xsl:call-template name="LocalisedString">
                <xsl:with-param name="term">rdfs:label</xsl:with-param>
              </xsl:call-template>
            </dct:RightsStatement>
          </dct:accessRights>
        </xsl:when>
        <xsl:when test="gmd:MD_RestrictionCode">
          <xsl:variable name="access-constraints-code" select="normalize-space(@codeListValue)"/>
          <xsl:variable name="access-constraints-text">
            <xsl:choose>
              <xsl:when test="normalize-space(.) != ''">
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:when>
              <xsl:when test="$access-constraints-code != ''">
                <xsl:value-of select="$access-constraints-code"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <dct:accessRights>
            <dct:RightsStatement>
              <xsl:if test="$access-constraints-code != ''">
                <dct:identifier>
                  <xsl:value-of select="$access-constraints-code"/>
                </dct:identifier>
              </xsl:if>
              <rdfs:label xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="$access-constraints-text"/>
              </rdfs:label>
              <xsl:call-template name="LocalisedString">
                <xsl:with-param name="term">rdfs:label</xsl:with-param>
              </xsl:call-template>
            </dct:RightsStatement>
          </dct:accessRights>
        </xsl:when>
        <xsl:when test="gmx:Anchor/@xlink:href">
          <dct:accessRights rdf:resource="{geonet:escapeURI(gmx:Anchor/@xlink:href)}"/>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- Keyword -->
  <xsl:template name="Keyword" match="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords">
    <xsl:param name="MetadataLanguage"/>
    <xsl:param name="ResourceType"/>
    <xsl:param name="ServiceType"/>
    <xsl:param name="OriginatingControlledVocabulary">
      <xsl:for-each select="gmd:thesaurusName/gmd:CI_Citation">
        <xsl:for-each select="gmd:title">
          <dct:title xml:lang="{$MetadataLanguage}">
            <xsl:value-of select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
          </dct:title>
          <xsl:call-template name="LocalisedString">
            <xsl:with-param name="term">dct:title</xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
        <xsl:apply-templates select="gmd:date/gmd:CI_Date"/>
      </xsl:for-each>
    </xsl:param>
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
    <xsl:variable name="isThesaurusTitle" select="normalize-space($firstThesaurus/gco:CharacterString) != ''"/>

    <xsl:for-each select="gmd:keyword">
      <xsl:variable name="lckw" select="translate(gco:CharacterString,$uppercase,$lowercase)"/>
      <xsl:choose>

        <xsl:when test="normalize-space($OriginatingControlledVocabulary) = '' and not( gmx:Anchor/@xlink:href and ( starts-with(gmx:Anchor/@xlink:href, 'http://') or starts-with(gmx:Anchor/@xlink:href, 'https://') ) )">
          <dcat:keyword xml:lang="{$MetadataLanguage}">
            <xsl:value-of select="normalize-space(gco:CharacterString)"/>
          </dcat:keyword>
          <xsl:call-template name="LocalisedString">
            <xsl:with-param name="term">dcat:keyword</xsl:with-param>
          </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
          <xsl:variable name="scheme">
            <xsl:choose>
              <xsl:when test="$isThesaurusTitle">
                <xsl:call-template name="GetSchemeFromThesaurusTitle">
                  <xsl:with-param name="thesaurusTitle" select="$thesaurusIdentifier"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$thesaurusIdentifier"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:choose>
            <!-- In case the concept's URI is NOT provided -->
            <xsl:when test="gco:CharacterString">
              <xsl:choose>
                <xsl:when test="$ResourceType != 'service'">
                  <xsl:variable name="keywordAbout">
                    <xsl:call-template name="GetAboutFromCharacterString">
                      <xsl:with-param name="keyword" select="normalize-space(gco:CharacterString)"/>
                      <xsl:with-param name="thesaurusIdentifier" select="$thesaurusIdentifier"/>
                      <xsl:with-param name="lang" select="$MetadataLanguage"/>
                    </xsl:call-template>
                  </xsl:variable>

                  <xsl:choose>
                    <xsl:when test="$keywordAbout">
                      <dcat:theme>
                        <skos:Concept>
                          <xsl:if test="normalize-space($keywordAbout) != ''">
                            <xsl:attribute name="rdf:about" select="geonet:escapeURI($keywordAbout)"/>
                          </xsl:if>
                          <skos:prefLabel xml:lang="{$MetadataLanguage}">
                            <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                          </skos:prefLabel>
                          <xsl:call-template name="LocalisedString">
                            <xsl:with-param name="term">skos:prefLabel</xsl:with-param>
                          </xsl:call-template>
                          <skos:inScheme rdf:resource="{$scheme}"/>
                        </skos:Concept>
                      </dcat:theme>
                    </xsl:when>
                    <xsl:otherwise>
                      <dcat:theme>
                        <skos:prefLabel xml:lang="{$MetadataLanguage}">
                          <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                        </skos:prefLabel>
                        <xsl:call-template name="LocalisedString">
                          <xsl:with-param name="term">skos:prefLabel</xsl:with-param>
                        </xsl:call-template>
                        <skos:inScheme>
                          <skos:ConceptScheme>
                            <xsl:copy-of select="$OriginatingControlledVocabulary"/>
                          </skos:ConceptScheme>
                        </skos:inScheme>
                      </dcat:theme>
                    </xsl:otherwise>
                  </xsl:choose>

                  <!-- Workaround: Always add a dcat:keyword alongs with the dcat:theme -->
                  <dcat:keyword xml:lang="{$MetadataLanguage}">
                    <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                  </dcat:keyword>
                  <xsl:call-template name="LocalisedString">
                    <xsl:with-param name="term">dcat:keyword</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>

                <xsl:otherwise>
                  <dct:subject>
                    <skos:prefLabel xml:lang="{$MetadataLanguage}">
                      <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                    </skos:prefLabel>
                    <xsl:call-template name="LocalisedString">
                      <xsl:with-param name="term">skos:prefLabel</xsl:with-param>
                    </xsl:call-template>
                    <skos:inScheme>
                      <skos:ConceptScheme>
                        <xsl:copy-of select="$OriginatingControlledVocabulary"/>
                      </skos:ConceptScheme>
                    </skos:inScheme>
                  </dct:subject>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- In case the concept's URI is provided -->
            <xsl:when test="gmx:Anchor/@xlink:href">
              <xsl:choose>
                <xsl:when test="$ResourceType != 'service'">
                  <dcat:theme>
                    <skos:Concept>
                      <xsl:if test="normalize-space(gmx:Anchor/@xlink:href) != ''">
                        <xsl:attribute name="rdf:about" select="geonet:escapeURI(gmx:Anchor/@xlink:href)"/>
                      </xsl:if>
                      <skos:prefLabel xml:lang="{$MetadataLanguage}">
                        <xsl:value-of select="gmx:Anchor"/>
                      </skos:prefLabel>
                      <xsl:call-template name="LocalisedString">
                        <xsl:with-param name="term">skos:prefLabel</xsl:with-param>
                      </xsl:call-template>
                      <skos:inScheme rdf:resource="{$scheme}"/>
                    </skos:Concept>
                  </dcat:theme>
                  <!-- Workaround: Always add a dcat:keyword alongs with the dcat:theme -->
                  <dcat:keyword xml:lang="{$MetadataLanguage}">
                    <xsl:value-of select="normalize-space(gmx:Anchor)"/>
                  </dcat:keyword>
                  <xsl:call-template name="LocalisedString">
                    <xsl:with-param name="term">dcat:keyword</xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <dct:subject rdf:resource="{geonet:escapeURI(gmx:Anchor/@xlink:href)}"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- Topic category -->
  <xsl:template name="TopicCategory" match="gmd:identificationInfo/*/gmd:topicCategory">
    <xsl:param name="TopicCategory">
      <xsl:value-of select="normalize-space(gmd:MD_TopicCategoryCode)"/>
    </xsl:param>
    <xsl:if test="$TopicCategory != ''">
      <dct:subject rdf:resource="{$TopicCategoryCodelistUri}/{$TopicCategory}"/>
    </xsl:if>
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
          <skos:prefLabel>
            <xsl:value-of select="."/>
          </skos:prefLabel>
          <rdfs:label>
            <xsl:value-of select="."/>
          </rdfs:label>
        </dct:format>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Maintenance information -->
  <xsl:template name="MaintenanceInformation" match="gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode">
    <!-- The following parameter maps frequency codes used in ISO 19139 metadata to the corresponding ones of the Dublin Core Collection Description Frequency Vocabulary (when available). -->
    <xsl:param name="FrequencyCodeURI">
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
    </xsl:param>
    <xsl:if test="$FrequencyCodeURI != ''">
      <dct:accrualPeriodicity rdf:resource="{geonet:escapeURI($FrequencyCodeURI)}"/>
    </xsl:if>
  </xsl:template>

  <!-- Spatial representation type (tentative) -->
  <xsl:template name="SpatialRepresentationType" match="gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode">
    <adms:representationTechnique rdf:resource="{$SpatialRepresentationTypeCodelistUri}/{@codeListValue}"/>
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

  <xsl:template name="Alpha3-to-Alpha2">
    <xsl:param name="lang"/>
    <xsl:choose>
      <xsl:when test="$lang = 'bul'">
        <xsl:text>bg</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'cze'">
        <xsl:text>cs</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'dan'">
        <xsl:text>da</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'ger'">
        <xsl:text>de</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'gre'">
        <xsl:text>el</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'eng'">
        <xsl:text>en</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'spa'">
        <xsl:text>es</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'est'">
        <xsl:text>et</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'fin'">
        <xsl:text>fi</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'fre'">
        <xsl:text>fr</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'gle'">
        <xsl:text>ga</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'hrv'">
        <xsl:text>hr</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'ita'">
        <xsl:text>it</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'lav'">
        <xsl:text>lv</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'lit'">
        <xsl:text>lt</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'hun'">
        <xsl:text>hu</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'mlt'">
        <xsl:text>mt</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'dut'">
        <xsl:text>nl</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'pol'">
        <xsl:text>pl</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'por'">
        <xsl:text>pt</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'rum'">
        <xsl:text>ru</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'slo'">
        <xsl:text>sk</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'slv'">
        <xsl:text>sl</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'swe'">
        <xsl:text>sv</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lang"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Map-language">
    <xsl:param name="lang"/>
    <xsl:choose>
      <xsl:when test="$lang = 'DUT'">
        <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/NLD">
          <rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
          <skos:prefLabel xml:lang="de">Niederländisch</skos:prefLabel>
          <skos:prefLabel xml:lang="en">Dutch</skos:prefLabel>
          <skos:prefLabel xml:lang="fr">néerlandais</skos:prefLabel>
          <skos:prefLabel xml:lang="nl">Nederlands</skos:prefLabel>
          <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
        </skos:Concept>
      </xsl:when>
      <xsl:when test="$lang = 'ENG'">
        <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/ENG">
          <rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
          <skos:prefLabel xml:lang="de">Englisch</skos:prefLabel>
          <skos:prefLabel xml:lang="en">English</skos:prefLabel>
          <skos:prefLabel xml:lang="fr">anglais</skos:prefLabel>
          <skos:prefLabel xml:lang="nl">Engels</skos:prefLabel>
          <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
        </skos:Concept>
      </xsl:when>
      <xsl:when test="$lang = ('FRE', 'FRA')">
        <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/FRA">
          <rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
          <skos:prefLabel xml:lang="de">Französisch</skos:prefLabel>
          <skos:prefLabel xml:lang="en">French</skos:prefLabel>
          <skos:prefLabel xml:lang="fr">français</skos:prefLabel>
          <skos:prefLabel xml:lang="nl">Frans</skos:prefLabel>
          <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
        </skos:Concept>
      </xsl:when>
      <xsl:when test="$lang = 'GER'">
        <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/DEU">
          <rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
          <skos:prefLabel xml:lang="de">Deutsch</skos:prefLabel>
          <skos:prefLabel xml:lang="en">German</skos:prefLabel>
          <skos:prefLabel xml:lang="fr">allemand</skos:prefLabel>
          <skos:prefLabel xml:lang="nl">Duits</skos:prefLabel>
          <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
        </skos:Concept>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Map-format">
    <xsl:param name="protocol"/>
    <xsl:param name="url"/>

    <xsl:choose>

      <xsl:when test="ends-with($protocol, 'get-capabilities')">
        <xsl:value-of select="'application/xml'"/>
      </xsl:when>

      <xsl:when test="ends-with($protocol, 'get-map')">
        <xsl:value-of select="geonet:getQueryParamValue($url, 'format')"/>
      </xsl:when>

      <xsl:when test="ends-with($protocol, 'get-tile')">
        <xsl:value-of select="geonet:getQueryParamValue($url, 'format')"/>
      </xsl:when>

      <xsl:when test="ends-with($protocol, 'get-coverage')">
        <xsl:value-of select="geonet:getQueryParamValue($url, 'format')"/>
      </xsl:when>

      <xsl:when test="ends-with($protocol, 'get-feature')">
        <xsl:variable name="format" select="geonet:getQueryParamValue($url, 'outputFormat')"/>
        <xsl:choose>
          <xsl:when test="$format">
            <xsl:value-of select="$format"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'GML'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

    </xsl:choose>
  </xsl:template>

  <xsl:template name="withoutType">
    <xsl:param name="description" as="node()"/>
    <xsl:for-each select="$description/*[name() != 'rdf:type']">
      <xsl:copy-of select="."/>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="geonet:getQueryParamValue">
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="queryParam" as="xs:string"/>
    <xsl:variable name="value" select="substring-after(lower-case($url), concat(lower-case($queryParam), '='))"/>
    <xsl:value-of select="normalize-space(if (contains($value, '&amp;')) then substring-before($value, '&amp;') else $value)"/>
  </xsl:function>

  <xsl:function name="geonet:getElementName">
    <xsl:param name="description" as="node()"/>
    <xsl:variable name="type" select="string($description/rdf:type/@rdf:resource)"/>
    <xsl:choose>
      <xsl:when test="$type = concat($dcat, 'Dataset')">
        <xsl:value-of select="'dcat:Dataset'"/>
      </xsl:when>
      <xsl:when test="$type = concat($dcat, 'DataService')">
        <xsl:value-of select="'dcat:DataService'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('WARNING: &quot;', $type, '&quot; does not have an element name')"/>
        <xsl:value-of select="'dcat:Dataset'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="geonet:escapeURI">
    <xsl:param name="uri"/>
    <xsl:if test="$uri">
      <xsl:value-of select="replace(normalize-space($uri), ' ', '%20')"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="geonet:getLabel">
    <xsl:param name="el"/>
    <xsl:choose>
      <xsl:when test="$el/gmx:Anchor">
        <xsl:value-of select="normalize-space($el/gmx:Anchor)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($el/gco:CharacterString)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
