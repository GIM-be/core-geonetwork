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
                xmlns:gsp="http://www.opengis.net/ont/geosparql#"
                xmlns:i="http://inspire.ec.europa.eu/schemas/common/1.0"
                xmlns:i-gp="http://inspire.ec.europa.eu/schemas/geoportal/1.0"
                xmlns:locn="http://www.w3.org/ns/locn#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:org="http://www.w3.org/ns/org#"
                xmlns:prov="http://www.w3.org/ns/prov#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:schema="http://schema.org/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:wdrs="http://www.w3.org/2007/05/powder-s#"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:geodcat="http://data.europa.eu/930/"
                xmlns:dqv="http://www.w3.org/ns/dqv#"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xslutil="java:org.fao.geonet.util.XslUtil"
                exclude-result-prefixes="earl gco gmd gml gmx i i-gp srv xlink xsi xsl wdrs cnt dctype dc gml320 xs prov gsp org geodcat dqv xslutil"
                version="2.0">

  <xsl:output method="xml"
              indent="yes"
              encoding="utf-8"
              cdata-section-elements="locn:geometry" />

  <xsl:include href="../convert/keyword_CharacterString_to_Anchor.xsl"/>
  <xsl:include href="../convert/TopicCatToDataGov.xsl"/>

  <!--
    The current specifications for the core and extended GeoDCAT-AP profiles are available on the Joinup collaboration platform:
    https://joinup.ec.europa.eu/node/139283/
  -->

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

  <xsl:variable name="modelLicencieKeywords">
    <license>
      <url>https://data.vlaanderen.be/id/licentie/modellicentie-gratis-hergebruik/v1.0</url>
      <urlKeyword>modellicentie-gratis-hergebruik</urlKeyword>
      <urlKeyword>modellicentie_gratis_hergebruik</urlKeyword>
      <content>
        <dct:license>
          <dct:LicenseDocument rdf:about="https://data.vlaanderen.be/id/licentie/modellicentie-gratis-hergebruik/v1.0" xmlns:dct="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            <dct:type>
              <skos:Concept rdf:about="http://purl.org/adms/licencetype/Attribution">
                <skos:prefLabel xml:lang="nl">Verplichte bronvermelding</skos:prefLabel>
                <skos:prefLabel xml:lang="en">Attribution</skos:prefLabel>
                <skos:prefLabel xml:lang="fr">Attribution</skos:prefLabel>
                <skos:prefLabel xml:lang="de">Attribution</skos:prefLabel>
                <skos:inScheme rdf:resource="http://purl.org/adms/licencetype/1.0" />
              </skos:Concept>
            </dct:type>
            <dct:title xml:lang="nl">Modellicentie voor gratis hergebruik</dct:title>
            <dct:description xml:lang="nl">Onder deze licentie doet de instantie geen afstand van haar intellectuele rechten, maar mag de data voor eender welk doel hergebruikt worden, gratis en onder minimale restricties.</dct:description>
            <dct:identifier>https://data.vlaanderen.be/id/licentie/modellicentie-gratis-hergebruik/v1.0</dct:identifier>
          </dct:LicenseDocument>
        </dct:license>
      </content>
    </license>
    <license>
      <url>https://data.vlaanderen.be/id/licentie/onvoorwaardelijk-hergebruik/v1.0</url>
      <urlKeyword>onvoorwaardelijk-hergebruik</urlKeyword>
      <urlKeyword>onvoorwaardelijk_hergebruik</urlKeyword>
      <content>
        <dct:license>
          <dct:LicenseDocument rdf:about="https://data.vlaanderen.be/id/licentie/onvoorwaardelijk-hergebruik/v1.0" xmlns:dct="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            <dct:type>
              <skos:Concept rdf:about="http://purl.org/adms/licencetype/PublicDomain">
                <skos:prefLabel xml:lang="nl">Werk in het publiek domein</skos:prefLabel>
                <skos:prefLabel xml:lang="en">Public domain</skos:prefLabel>
                <skos:prefLabel xml:lang="fr">Public domain</skos:prefLabel>
                <skos:prefLabel xml:lang="de">Public domain</skos:prefLabel>
                <skos:inScheme rdf:resource="http://purl.org/adms/licencetype/1.0" />
              </skos:Concept>
            </dct:type>
            <dct:title xml:lang="nl">Onvoorwaardelijk hergebruik</dct:title>
            <dct:description xml:lang="nl">Onvoorwaardelijk hergebruik</dct:description>
            <dct:identifier>https://data.vlaanderen.be/id/licentie/onvoorwaardelijk-hergebruik/v1.0</dct:identifier>
          </dct:LicenseDocument>
        </dct:license>
      </content>
    </license>
    <license>
      <url>https://data.vlaanderen.be/id/licentie/modellicentie-hergebruik-tegen-vergoeding/v1.0</url>
      <urlKeyword>modellicentie-hergebruik-tegen-vergoeding</urlKeyword>
      <urlKeyword>modellicentie_hergebruik_tegen_vergoeding</urlKeyword>
      <content>
        <dct:license>
          <dct:LicenseDocument rdf:about="https://data.vlaanderen.be/id/licentie/modellicentie-hergebruik-tegen-vergoeding/v1.0" xmlns:dct="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            <dct:type>
              <skos:Concept rdf:about="http://purl.org/adms/licencetype/Attribution">
                <skos:prefLabel xml:lang="nl">Verplichte bronvermelding</skos:prefLabel>
                <skos:prefLabel xml:lang="en">Attribution</skos:prefLabel>
                <skos:prefLabel xml:lang="fr">Attribution</skos:prefLabel>
                <skos:prefLabel xml:lang="de">Attribution</skos:prefLabel>
                <skos:inScheme rdf:resource="http://purl.org/adms/licencetype/1.0" />
              </skos:Concept>
            </dct:type>
            <dct:title xml:lang="nl">Modellicentie voor hergebruik tegen vergoeding</dct:title>
            <dct:description xml:lang="nl">Onder deze licentie stelt de instantie nog steeds haar data ter beschikking voor eender welk hergebruik, maar wil zij hiervoor een vergoeding ontvangen. In regel is deze vergoeding beperkt tot de marginale kosten voor vermenigvuldiging, verstrekking en verspreiding.</dct:description>
            <dct:identifier>https://data.vlaanderen.be/id/licentie/modellicentie-hergebruik-tegen-vergoeding/v1.0</dct:identifier>
          </dct:LicenseDocument>
        </dct:license>
      </content>
    </license>
    <license>
      <url>https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0</url>
      <urlKeyword>creative-commons-zero-verklaring</urlKeyword>
      <urlKeyword>creative_commons_zero_verklaring</urlKeyword>
      <urlKeyword>publicdomain/zero</urlKeyword>
      <urlKeyword>cc0</urlKeyword>
      <content>
        <dct:license>
          <dct:LicenseDocument rdf:about="https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0" xmlns:dct="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            <dct:type>
              <skos:Concept rdf:about="http://purl.org/adms/licencetype/PublicDomain">
                <skos:prefLabel xml:lang="nl">Werk in het publiek domein</skos:prefLabel>
                <skos:prefLabel xml:lang="en">Public domain</skos:prefLabel>
                <skos:prefLabel xml:lang="fr">Public domain</skos:prefLabel>
                <skos:prefLabel xml:lang="de">Public domain</skos:prefLabel>
                <skos:inScheme rdf:resource="http://purl.org/adms/licencetype/1.0"/>
              </skos:Concept>
            </dct:type>
            <dct:title xml:lang="nl">Creative Commons Zero verklaring</dct:title>
            <dct:description xml:lang="nl">De instantie doet afstand van haar intellectuele eigendomsrechten voor zover dit wettelijk mogelijk is. Hierdoor kan de gebruiker de data hergebruiken voor eender welk doel, zonder een verplichting op naamsvermelding. Deze is de welbekende CC0 licentie.</dct:description>
            <dct:identifier>https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0</dct:identifier>
          </dct:LicenseDocument>
        </dct:license>
      </content>
    </license>
    <license>
      <url>https://overheid.vlaanderen.be/Webdiensten-Gebruiksrecht</url>
      <urlKeyword>Webdiensten-Gebruiksrecht</urlKeyword>
      <urlKeyword>webdiensten-gebruiksrecht</urlKeyword>
      <scope>service</scope>
      <content>
        <dct:license>
          <dct:LicenseDocument rdf:about="https://overheid.vlaanderen.be/Webdiensten-Gebruiksrecht">
            <dct:type>
              <skos:Concept rdf:about="http://purl.org/adms/licencetype/JurisdictionWithinTheEU">
                <skos:prefLabel xml:lang="nl">Rechtsbevoegheid binnen de EU</skos:prefLabel>
                <skos:prefLabel xml:lang="en">Jurisdiction within the EU</skos:prefLabel>
                <skos:prefLabel xml:lang="fr">Jurisdiction within the EU</skos:prefLabel>
                <skos:prefLabel xml:lang="de">Jurisdiction within the EU</skos:prefLabel>
                <skos:inScheme rdf:resource="http://purl.org/adms/licencetype/1.0"/>
              </skos:Concept>
            </dct:type>
            <dct:title xml:lang="nl">Gebruiksrecht en privacyverklaring geografische webdiensten</dct:title>
            <dct:description xml:lang="nl">Door het gebruik van de service verbindt elke gebruiker of raadpleger er zich toe om zich te houden aan de toegangs- en gebruiksbepalingen van de in de service aangeboden gegevens.</dct:description>
            <dct:identifier>https://overheid.vlaanderen.be/Webdiensten-Gebruiksrecht</dct:identifier>
          </dct:LicenseDocument>
        </dct:license>
      </content>
    </license>
  </xsl:variable>

  <!--
    Metadata template
    =================
   -->
  <xsl:template match="gmd:MD_Metadata|//gmd:MD_Metadata" mode="to-dcat">
    <xsl:param name="MetadataViewUrl">
      <xsl:value-of select="concat($catalogUrl, '/catalog.search#/metadata/', gmd:fileIdentifier/gco:CharacterString)"/>
    </xsl:param>

    <!-- Metadata language: corresponding Alpha-2 codes -->
    <xsl:param name="recordLang">
      <xsl:call-template name="ExtractLang">
        <xsl:with-param name="lang" select="gmd:language"/>
      </xsl:call-template>
    </xsl:param>

    <xsl:param name="MetadataLanguage">
      <xsl:call-template name="Alpha3-to-Alpha2">
        <xsl:with-param name="lang" select="$recordLang"/>
      </xsl:call-template>
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
          <xsl:value-of select="xslutil:uuidFromString($RecordUUID)"/>
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

    <xsl:param name="LicenseAndRightsConstraints">
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
    </xsl:param>


    <xsl:param name="AccessRights">
      <!-- Mapping revised for compliance with the 2017 edition of the INSPIRE Metadata Technical Guidelines -->
      <xsl:variable name="firstConstraint" select="gmd:identificationInfo[count(*/gmd:resourceConstraints/*/gmd:accessConstraints) > 0]/*/gmd:resourceConstraints/*"/>
      <xsl:choose>
        <xsl:when test="$firstConstraint/gmd:otherConstraints/gmx:Anchor/@xlink:href">
          <xsl:variable name="asNoLimitation" select="count($firstConstraint/gmd:otherConstraints/gmx:Anchor/@xlink:href[. = ('http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations','https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations')]) > 0"/>
          <xsl:choose>
            <xsl:when test="$asNoLimitation">
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
            </xsl:when>
            <xsl:otherwise>
              <dct:accessRights rdf:resource="{geonet:escapeURI(($firstConstraint/gmd:otherConstraints/gmx:Anchor/@xlink:href)[1])}"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$firstConstraint/gmd:accessConstraints/gmd:MD_RestrictionCode">
          <xsl:variable name="accessConstraintsCode" select="normalize-space(($firstConstraint/gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue)[1])"/>
          <xsl:variable name="accessConstraintsText">
            <xsl:choose>
              <xsl:when test="normalize-space(.) != ''">
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:when>
              <xsl:when test="$accessConstraintsCode != ''">
                <xsl:value-of select="$accessConstraintsCode"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <dct:accessRights>
            <dct:RightsStatement>
              <xsl:if test="$accessConstraintsCode != ''">
                <dct:identifier>
                  <xsl:value-of select="$accessConstraintsCode"/>
                </dct:identifier>
              </xsl:if>
              <rdfs:label xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="$accessConstraintsText"/>
              </rdfs:label>
              <xsl:call-template name="LocalisedString">
                <xsl:with-param name="term">rdfs:label</xsl:with-param>
              </xsl:call-template>
            </dct:RightsStatement>
          </dct:accessRights>
        </xsl:when>
        <xsl:when test="$firstConstraint/gmd:otherConstraints/gco:CharacterString">
          <dct:accessRights>
            <dct:RightsStatement>
              <rdfs:label xml:lang="{$MetadataLanguage}">
                <xsl:value-of select="normalize-space(($firstConstraint/gmd:otherConstraints/gco:CharacterString)[1])"/>
              </rdfs:label>
              <xsl:call-template name="LocalisedString">
                <xsl:with-param name="term">rdfs:label</xsl:with-param>
              </xsl:call-template>
            </dct:RightsStatement>
          </dct:accessRights>
        </xsl:when>
      </xsl:choose>
    </xsl:param>

    <!-- Metadata character encoding -->

    <xsl:param name="MetadataCharacterEncoding">
      <xsl:apply-templates select="gmd:characterSet/gmd:MD_CharacterSetCode"/>
    </xsl:param>

    <xsl:param name="ResourceCharacterEncoding">
      <xsl:for-each select="gmd:identificationInfo/gmd:MD_DataIdentification">
        <xsl:apply-templates select="gmd:characterSet/gmd:MD_CharacterSetCode"/>
      </xsl:for-each>
    </xsl:param>

    <!-- Metadata description (metadata on metadata) -->
    <xsl:param name="MetadataDescription">
      <dct:identifier>
        <xsl:value-of select="$RecordUUID"/>
      </dct:identifier>

      <xsl:if test="$recordLang != ''">
        <xsl:variable name="languageConcept">
          <xsl:call-template name="Map-language">
            <xsl:with-param name="lang" select="translate($recordLang, $lowercase, $uppercase)"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="normalize-space($languageConcept) != ''">
            <dct:language>
              <xsl:copy-of select="$languageConcept"/>
            </dct:language>
          </xsl:when>
          <xsl:otherwise>
            <dct:language rdf:resource="{geonet:escapeURI(concat($oplang, translate($recordLang, $lowercase, $uppercase)))}"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:if test="$MetadataDate != ''">
        <dct:modified>
          <xsl:value-of select="$MetadataDate"/>
        </dct:modified>
      </xsl:if>

      <xsl:variable name="standardName" select="geonet:getLabel(gmd:metadataStandardName)"/>
      <xsl:variable name="standardVersion" select="geonet:getLabel(gmd:metadataStandardVersion)"/>

      <xsl:if test="$standardName != '' or $standardVersion != ''">
        <dct:conformsTo>
          <dct:Standard>
            <dct:title>GeoDCAT-AP-VL</dct:title>
          </dct:Standard>
        </dct:conformsTo>
      </xsl:if>

      <xsl:if test="$MetadataCharacterEncoding != ''">
        <xsl:copy-of select="$MetadataCharacterEncoding"/>
      </xsl:if>
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

      <!-- Unique Resource identification info -->
      <dct:identifier>
        <xsl:value-of select="$ResourceUUID"/>
      </dct:identifier>
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/*/gmd:identifier/*[concat(gmd:codeSpace/gco:CharacterString, gmd:code/gco:CharacterString) != $ResourceUUID]"/>
      <xsl:copy-of select="$ResourceTitle"/>
      <xsl:copy-of select="$ResourceAbstract"/>

      <!-- Topic category -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:topicCategory">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <!-- Keyword -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
        <xsl:with-param name="ResourceType" select="$ResourceType"/>
      </xsl:apply-templates>

      <!-- Alternate title -->
      <xsl:apply-templates select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:alternateTitle">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
        <xsl:with-param name="ResourceType" select="$ResourceType"/>
      </xsl:apply-templates>

      <!-- Reference system information -->
      <xsl:apply-templates select="gmd:referenceSystemInfo">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
        <xsl:with-param name="ResourceType" select="$ResourceType"/>
      </xsl:apply-templates>

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
              <dct:language rdf:resource="{geonet:escapeURI(concat($oplang, translate($recordLang, $lowercase, $uppercase)))}"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>

      <!-- Temporal extent -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:extent/gmd:EX_Extent/gmd:temporalElement/gmd:EX_TemporalExtent"/>

      <!-- Creation date, publication date, date of last revision -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation"/>

      <!-- Conformity -->
      <xsl:apply-templates select="gmd:dataQualityInfo/*/gmd:report/*/gmd:result/*/gmd:specification/gmd:CI_Citation">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <!-- Responsible organisation -->
      <xsl:for-each select="//gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'publisher'][1]|
                            //gmd:CI_ResponsibleParty[gmd:role/gmd:CI_RoleCode/@codeListValue = 'owner'][1]">
        <xsl:apply-templates select=".">
          <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
          <xsl:with-param name="ResourceType" select="$ResourceType"/>
        </xsl:apply-templates>
      </xsl:for-each>

      <xsl:for-each select="//gmd:CI_ResponsibleParty[not(gmd:role/gmd:CI_RoleCode/@codeListValue = ('publisher', 'owner'))]">
        <xsl:apply-templates select=".">
          <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
          <xsl:with-param name="ResourceType" select="$ResourceType"/>
        </xsl:apply-templates>
      </xsl:for-each>

      <dct:relation rdf:resource="{geonet:escapeURI($MetadataViewUrl)}"/>

      <!-- Spatial extend -->
      <xsl:apply-templates select="gmd:identificationInfo[1]/*/*[self::gmd:extent|self::srv:extent]/*/gmd:geographicElement">
        <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>
      </xsl:apply-templates>

      <!-- spatial resolution -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution"/>

      <!-- Version information -->
      <xsl:apply-templates select="gmd:identificationInfo/*/gmd:citation/*/gmd:edition"/>

      <!-- Access Rights -->
      <xsl:copy-of select="$AccessRights"/>

      <!-- Resource type specific -->
      <xsl:choose>
        <!-- Service specific -->
        <xsl:when test="$ResourceType = 'service'">
          <!-- Contains operations -->
          <xsl:for-each-group select="gmd:identificationInfo/*/srv:containsOperations/srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL" group-by=".">
            <dcat:endpointUrl rdf:resource="{normalize-space(current-grouping-key())}"/>
          </xsl:for-each-group>

          <xsl:for-each-group select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:linkage/gmd:URL" group-by=".">
            <dcat:endpointDescription rdf:resource="{normalize-space(current-grouping-key())}"/>
          </xsl:for-each-group>

          <!-- Online resources -->
          <xsl:for-each-group select="gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource/gmd:protocol/*" group-by=".">
            <!-- Conform to standard -->
            <xsl:if test="normalize-space(current-grouping-key()) != ''">
              <!-- TODO: map to INSPIRE-PV codelist values: https://inspire.ec.europa.eu/metadata-codelist/ProtocolValue -->
              <dct:conformsTo>
                <dct:Standard>
                  <dct:title>
                    <xsl:value-of select="current-grouping-key()"/>
                  </dct:title>
                </dct:Standard>
              </dct:conformsTo>
            </xsl:if>
          </xsl:for-each-group>
          <xsl:copy-of select="$LicenseAndRightsConstraints"/>

          <!-- Coupled resources -->
          <xsl:for-each select="gmd:identificationInfo[1]/*/srv:operatesOn">
            <dcat:servesDataset rdf:resource="{@xlink:href}"/>
          </xsl:for-each>
        </xsl:when>

        <!-- Dataset specific -->
        <xsl:when test="$ResourceType = 'dataset' or $ResourceType = 'series'">
          <!-- Lineage -->
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

          <!-- Maintenance information (tentative) -->
          <xsl:for-each select="gmd:identificationInfo/*/gmd:resourceMaintenance">
            <xsl:apply-templates select="gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode"/>
          </xsl:for-each>

          <!-- Spatial representation type -->
          <xsl:variable name="SpatialRepresentationType">
            <xsl:apply-templates select="gmd:identificationInfo/*/gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode"/>
          </xsl:variable>

          <!-- Related services -->
          <xsl:variable name="relatedUrl" select="concat($nodeUrl, 'api/records/', $RecordUUID, '/related?type=services')"/>
          <xsl:for-each select="document($relatedUrl)/related/services/item">
            <xsl:variable name="serviceUniqueIdentifiers">
              <xsl:for-each select="document(concat($nodeUrl, 'api/records/', id, '/formatters/xml'))/gmd:MD_Metadata/gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*">
                <xsl:choose>
                  <xsl:when test="gmd:codeSpace/gco:CharacterString/text() != ''">
                    <xsl:value-of select="concat(gmd:codeSpace/gco:CharacterString/text(), gmd:code/gco:CharacterString/text())"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="gmd:code/gco:CharacterString/text()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="serviceUuid">
              <xsl:choose>
                <xsl:when test="$serviceUniqueIdentifiers[matches(., $uuidRegex)][1]">
                  <xsl:value-of select="$serviceUniqueIdentifiers[matches(., $uuidRegex)][1]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="xslutil:uuidFromString(id)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="serviceUri" select="concat($resourcePrefix, '/service/', $serviceUuid)"/>
            <dct:relation rdf:resource="{geonet:escapeURI($serviceUri)}"/>
          </xsl:for-each>


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

              <xsl:variable name="Protocol" select="gmd:protocol/*/text()"/>

              <xsl:variable name="linkage" select="gmd:linkage"/>

              <xsl:variable name="Function" select="gmd:function/gmd:CI_OnLineFunctionCode/@codeListValue"/>

              <xsl:choose>
                <xsl:when test="normalize-space($Function) = ('download', 'offlineAccess', 'order', '')">
                  <xsl:if test="starts-with($Protocol, 'WWW:DOWNLOAD-1.0') or $Protocol = 'LINK download-store'">
                    <xsl:for-each select="$Encoding/dct:format">
                      <dcat:distribution>
                        <dcat:Distribution>
                          <xsl:copy-of select="$Title"/>
                          <xsl:copy-of select="$Description"/>
                          <xsl:for-each select="$linkage/gmd:URL">
                            <dcat:accessURL rdf:resource="{geonet:escapeURI(.)}"/>
                          </xsl:for-each>
                          <xsl:copy-of select="$LicenseAndRightsConstraints"/>
                          <xsl:copy-of select="$SpatialRepresentationType"/>
                          <xsl:copy-of select="."/>
                          <dct:conformsTo>
                            <dct:Standard>
                              <dct:title>
                                <xsl:value-of select="$Protocol"/>
                              </dct:title>
                            </dct:Standard>
                          </dct:conformsTo>
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
                  <xsl:for-each select="$linkage/gmd:URL">
                    <dcat:landingPage rdf:resource="{geonet:escapeURI(.)}"/>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>

            </xsl:for-each>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:param>

    <!-- Output Catalog record and resource description -->
    <xsl:choose>
      <xsl:when test="$ResourceUri != ''">
        <xsl:choose>
          <xsl:when test="$MetadataUri != ''">
            <dcat:CatalogRecord>
              <xsl:if test="normalize-space($MetadataUri) != ''">
                <xsl:attribute name="rdf:about" select="$MetadataUri"/>
              </xsl:if>
              <foaf:primaryTopic rdf:resource="{$ResourceUri}"/>
              <adms:identifier>
                <adms:Identifier>
                  <skos:notation>
                    <xsl:value-of select="$MetadataUri"/>
                  </skos:notation>
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
            </adms:Identifier>
          </adms:identifier>
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
    <xsl:param name="ResourceType"/>

    <xsl:param name="role">
      <xsl:value-of select="gmd:role/gmd:CI_RoleCode/@codeListValue"/>
    </xsl:param>

    <xsl:param name="IndividualURI">
      <xsl:value-of select="geonet:escapeURI(gmd:individualName/*/@xlink:href)"/>
    </xsl:param>

    <xsl:param name="IndividualName">
      <xsl:value-of select="normalize-space(gmd:individualName/*)"/>
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
        <xsl:if test="$OrganisationName != ''">
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
    </xsl:param>

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
          <xsl:variable name="specinfo">
            <dct:title xml:lang="{$MetadataLanguage}">
              <xsl:value-of select="geonet:getLabel(gmd:title)"/>
            </dct:title>
            <!--<xsl:apply-templates select="gmd:date/gmd:CI_Date"/>-->
          </xsl:variable>
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
    <xsl:apply-templates select="gmd:EX_GeographicBoundingBox"/>
    <!--<xsl:apply-templates select="gmd:EX_GeographicDescription/gmd:geographicIdentifier/*">-->
    <!--  <xsl:with-param name="MetadataLanguage" select="$MetadataLanguage"/>-->
    <!--</xsl:apply-templates>-->
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

  <!-- Keyword -->
  <xsl:template name="Keyword" match="gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords">
    <xsl:param name="MetadataLanguage"/>
    <xsl:param name="ResourceType"/>
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
      </xsl:for-each>
    </xsl:param>
    <xsl:param name="firstThesaurus" select="gmd:thesaurusName/gmd:CI_Citation/gmd:title[1]"/>
    <xsl:param name="thesaurusIdentifier">
      <xsl:choose>
        <xsl:when test="$firstThesaurus/gmx:Anchor">
          <xsl:value-of select="$firstThesaurus/gmx:Anchor/@xlink:href"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space($firstThesaurus/gco:CharacterString)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:param name="scheme">
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
    </xsl:param>

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
          <dcat:keyword xml:lang="{$MetadataLanguage}">
            <xsl:value-of select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
          </dcat:keyword>
          <xsl:call-template name="LocalisedString">
            <xsl:with-param name="term">dcat:keyword</xsl:with-param>
          </xsl:call-template>
        </xsl:when>

        <xsl:when test="$scheme = ('http://vocab.belgif.be/auth/datatheme', 'http://vocab.belgif.be/auth/datatheme/')">
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
    <xsl:param name="ResourceType"/>
    <dcat:keyword xml:lang="{$MetadataLanguage}">
      <xsl:value-of select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
    </dcat:keyword>
  </xsl:template>

  <!-- Reference system info -->
  <xsl:template name="ReferenceSystemInfo" match="gmd:referenceSystemInfo">
    <xsl:param name="MetadataLanguage"/>
    <xsl:param name="ResourceType"/>
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
    <xsl:param name="TopicCategory">
      <xsl:value-of select="normalize-space(gmd:MD_TopicCategoryCode)"/>
    </xsl:param>
    <xsl:param name="DataGovTheme">
      <xsl:call-template name="MapTopicCatToDataGovTheme">
        <xsl:with-param name="TopicCategory" select="$TopicCategory"/>
      </xsl:call-template>
    </xsl:param>

    <xsl:choose>
      <xsl:when test="$DataGovTheme/dcat:theme">

        <xsl:variable name="alreadyAddedGovThemes">
          <xsl:for-each select="../gmd:descriptiveKeywords/gmd:MD_Keywords[gmd:thesaurusName/gmd:CI_Citation/gmd:title[1]/gmx:Anchor/@xlink:href = ('http://vocab.belgif.be/auth/datatheme', 'http://vocab.belgif.be/auth/datatheme/')]">
            <xsl:for-each select="gmd:keyword/gmx:Anchor">
              <theme>
                <xsl:value-of select="string(@xlink:href)"/>
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

  <!-- Spatial resolution -->
  <xsl:template name="SpatialResolution" match="gmd:identificationInfo/*/gmd:spatialResolution/gmd:MD_Resolution">
    <xsl:choose>
      <xsl:when test="gmd:distance/gco:Distance[@uom = 'm']">
        <dcat:spatialResolutionInMeters>
          <xsl:value-of select="string(gmd:distance/gco:Distance)"/>
        </dcat:spatialResolutionInMeters>
      </xsl:when>

      <!--TODO: gmd:equivalentScale-->
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

  <xsl:template name="ExtractLang" match="gmd:language">
    <xsl:param name="lang"/>
    <xsl:choose>
      <xsl:when test="$lang/gmd:LanguageCode/@codeListValue != ''">
        <xsl:value-of select="translate($lang/gmd:LanguageCode/@codeListValue, $uppercase, $lowercase)"/>
      </xsl:when>
      <xsl:when test="$lang/gmd:LanguageCode != ''">
        <xsl:value-of select="translate($lang/gmd:LanguageCode, $uppercase, $lowercase)"/>
      </xsl:when>
      <xsl:when test="$lang/gco:CharacterString != ''">
        <xsl:value-of select="translate($lang/gco:CharacterString, $uppercase, $lowercase)"/>
      </xsl:when>
    </xsl:choose>
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
