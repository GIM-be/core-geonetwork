<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:dct="http://purl.org/dc/terms/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">

  <!--
    Global parameters
    =======================
  -->

  <!-- Variables to be used to convert strings into lower/uppercase by using the translate() function. -->
  <xsl:variable name="lowercase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="uppercase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

  <!-- URIs, URNs and names for spatial reference system registers. -->
  <xsl:variable name="EpsgSrsBaseUri">http://www.opengis.net/def/crs/EPSG/0</xsl:variable>
  <xsl:variable name="EpsgSrsBaseUrn">urn:ogc:def:crs:EPSG</xsl:variable>
  <xsl:variable name="EpsgSrsName">EPSG Coordinate Reference Systems</xsl:variable>
  <xsl:variable name="OgcSrsBaseUri">http://www.opengis.net/def/crs/OGC</xsl:variable>
  <xsl:variable name="OgcSrsBaseUrn">urn:ogc:def:crs:OGC</xsl:variable>
  <xsl:variable name="OgcSrsName">OGC Coordinate Reference Systems</xsl:variable>

  <!-- URI and URN for CRS84. -->
  <xsl:variable name="Crs84Uri" select="concat($OgcSrsBaseUri,'/1.3/CRS84')"/>
  <xsl:variable name="Crs84Urn" select="concat($OgcSrsBaseUrn,':1.3:CRS84')"/>

  <!-- URI and URN for ETRS89. -->
  <xsl:variable name="Etrs89Uri" select="concat($EpsgSrsBaseUri,'/4258')"/>
  <xsl:variable name="Etrs89Urn" select="concat($EpsgSrsBaseUrn,'::4258')"/>

  <!-- URI and URN of the spatial reference system (SRS) used in the bounding box.
       The default SRS is CRS84. If a different SRS is used, also variableeter
       $SrsAxisOrder must be specified. -->

  <!-- The SRS URI is used in the WKT and GML encodings of the bounding box. -->
  <xsl:variable name="SrsUri" select="$Crs84Uri"/>
  <!-- The SRS URN is used in the GeoJSON encoding of the bounding box. -->
  <xsl:variable name="SrsUrn" select="$Crs84Urn"/>

  <!-- Axis order for the reference SRS:
       - "LonLat": longitude / latitude
       - "LatLon": latitude / longitude.
       The axis order must be specified only if the reference SRS is different from CRS84.
       If the reference SRS is CRS84, this variableeter is ignored. -->
  <xsl:variable name="SrsAxisOrder">LonLat</xsl:variable>

  <!-- Namespaces -->
  <xsl:variable name="xsd">http://www.w3.org/2001/XMLSchema#</xsl:variable>
  <xsl:variable name="dct">http://purl.org/dc/terms/</xsl:variable>
  <xsl:variable name="dctype">http://purl.org/dc/dcmitype/</xsl:variable>
  <xsl:variable name="dcat">http://www.w3.org/ns/dcat#</xsl:variable>
  <xsl:variable name="gsp">http://www.opengis.net/ont/geosparql#</xsl:variable>
  <xsl:variable name="foaf">http://xmlns.com/foaf/0.1/</xsl:variable>
  <xsl:variable name="vcard">http://www.w3.org/2006/vcard/ns#</xsl:variable>
  <xsl:variable name="op">http://publications.europa.eu/resource/authority/</xsl:variable>
  <xsl:variable name="opcountry" select="concat($op,'country/')"/>
  <xsl:variable name="oplang" select="concat($op,'language/')"/>
  <xsl:variable name="opcb" select="concat($op,'corporate-body/')"/>
  <xsl:variable name="opfq" select="concat($op,'frequency/')"/>
  <xsl:variable name="cldFrequency">http://purl.org/cld/freq/</xsl:variable>
  <!-- This is used as the datatype for the GeoJSON-based encoding of the bounding box. -->
  <xsl:variable name="geojsonMediaTypeUri">https://www.iana.org/assignments/media-types/application/vnd.geo+json
  </xsl:variable>

  <!-- INSPIRE code list URIs -->
  <xsl:variable name="INSPIRECodelistUri">http://inspire.ec.europa.eu/metadata-codelist/</xsl:variable>
  <xsl:variable name="SpatialDataServiceCategoryCodelistUri" select="concat($INSPIRECodelistUri,'SpatialDataServiceCategory')"/>
  <xsl:variable name="DegreeOfConformityCodelistUri" select="concat($INSPIRECodelistUri,'DegreeOfConformity')"/>
  <xsl:variable name="ResourceTypeCodelistUri" select="concat($INSPIRECodelistUri,'ResourceType')"/>
  <xsl:variable name="ResponsiblePartyRoleCodelistUri" select="concat($INSPIRECodelistUri,'ResponsiblePartyRole')"/>
  <xsl:variable name="SpatialDataServiceTypeCodelistUri" select="concat($INSPIRECodelistUri,'SpatialDataServiceType')"/>
  <xsl:variable name="TopicCategoryCodelistUri" select="concat($INSPIRECodelistUri,'TopicCategory')"/>

  <!-- INSPIRE code list URIs (not yet supported; the URI pattern is tentative) -->
  <xsl:variable name="SpatialRepresentationTypeCodelistUri" select="concat($INSPIRECodelistUri,'SpatialRepresentationTypeCode')"/>
  <xsl:variable name="MaintenanceFrequencyCodelistUri" select="concat($INSPIRECodelistUri,'MaintenanceFrequencyCode')"/>

  <!-- INSPIRE glossary URI -->
  <xsl:variable name="INSPIREGlossaryUri">http://inspire.ec.europa.eu/glossary/</xsl:variable>

  <!-- GIM custom variables -->
  <xsl:variable name="catalogUrl" select="concat(substring-before($resourcePrefix, '/resource'), '/dut')"/>
  <xsl:variable name="uuidRegex" select="'^([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}){1}$'"/>
  <xsl:variable name="relationLookup" select="true()"/>

  <xsl:variable name="modelLicencieKeywords">
    <license>
      <url>https://data.vlaanderen.be/id/licentie/modellicentie-gratis-hergebruik/v1.0</url>
      <urlKeyword>modellicentie-gratis-hergebruik</urlKeyword>
      <urlKeyword>modellicentie_gratis_hergebruik</urlKeyword>
      <content>
        <dct:license>
          <dct:LicenseDocument rdf:about="https://data.vlaanderen.be/id/licentie/modellicentie-gratis-hergebruik/v1.0"
                               xmlns:dct="http://purl.org/dc/terms/"
                               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                               xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            <dct:type>
              <skos:Concept rdf:about="http://purl.org/adms/licencetype/Attribution">
                <skos:prefLabel xml:lang="nl">Verplichte bronvermelding</skos:prefLabel>
                <skos:prefLabel xml:lang="en">Attribution</skos:prefLabel>
                <skos:prefLabel xml:lang="fr">Attribution</skos:prefLabel>
                <skos:prefLabel xml:lang="de">Attribution</skos:prefLabel>
                <skos:inScheme rdf:resource="http://purl.org/adms/licencetype/1.0"/>
              </skos:Concept>
            </dct:type>
            <dct:title xml:lang="nl">Modellicentie voor gratis hergebruik</dct:title>
            <dct:description xml:lang="nl">Onder deze licentie doet de instantie geen afstand van haar intellectuele
              rechten, maar mag de data voor eender welk doel hergebruikt worden, gratis en onder minimale restricties.
            </dct:description>
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
          <dct:LicenseDocument rdf:about="https://data.vlaanderen.be/id/licentie/onvoorwaardelijk-hergebruik/v1.0"
                               xmlns:dct="http://purl.org/dc/terms/"
                               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                               xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            <dct:type>
              <skos:Concept rdf:about="http://purl.org/adms/licencetype/PublicDomain">
                <skos:prefLabel xml:lang="nl">Werk in het publiek domein</skos:prefLabel>
                <skos:prefLabel xml:lang="en">Public domain</skos:prefLabel>
                <skos:prefLabel xml:lang="fr">Public domain</skos:prefLabel>
                <skos:prefLabel xml:lang="de">Public domain</skos:prefLabel>
                <skos:inScheme rdf:resource="http://purl.org/adms/licencetype/1.0"/>
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
          <dct:LicenseDocument
            rdf:about="https://data.vlaanderen.be/id/licentie/modellicentie-hergebruik-tegen-vergoeding/v1.0"
            xmlns:dct="http://purl.org/dc/terms/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:skos="http://www.w3.org/2004/02/skos/core#">
            <dct:type>
              <skos:Concept rdf:about="http://purl.org/adms/licencetype/Attribution">
                <skos:prefLabel xml:lang="nl">Verplichte bronvermelding</skos:prefLabel>
                <skos:prefLabel xml:lang="en">Attribution</skos:prefLabel>
                <skos:prefLabel xml:lang="fr">Attribution</skos:prefLabel>
                <skos:prefLabel xml:lang="de">Attribution</skos:prefLabel>
                <skos:inScheme rdf:resource="http://purl.org/adms/licencetype/1.0"/>
              </skos:Concept>
            </dct:type>
            <dct:title xml:lang="nl">Modellicentie voor hergebruik tegen vergoeding</dct:title>
            <dct:description xml:lang="nl">Onder deze licentie stelt de instantie nog steeds haar data ter beschikking
              voor eender welk hergebruik, maar wil zij hiervoor een vergoeding ontvangen. In regel is deze vergoeding
              beperkt tot de marginale kosten voor vermenigvuldiging, verstrekking en verspreiding.
            </dct:description>
            <dct:identifier>https://data.vlaanderen.be/id/licentie/modellicentie-hergebruik-tegen-vergoeding/v1.0
            </dct:identifier>
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
          <dct:LicenseDocument rdf:about="https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0"
                               xmlns:dct="http://purl.org/dc/terms/"
                               xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                               xmlns:skos="http://www.w3.org/2004/02/skos/core#">
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
            <dct:description xml:lang="nl">De instantie doet afstand van haar intellectuele eigendomsrechten voor zover
              dit wettelijk mogelijk is. Hierdoor kan de gebruiker de data hergebruiken voor eender welk doel, zonder
              een verplichting op naamsvermelding. Deze is de welbekende CC0 licentie.
            </dct:description>
            <dct:identifier>https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0
            </dct:identifier>
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
            <dct:description xml:lang="nl">Door het gebruik van de service verbindt elke gebruiker of raadpleger er zich
              toe om zich te houden aan de toegangs- en gebruiksbepalingen van de in de service aangeboden gegevens.
            </dct:description>
            <dct:identifier>https://overheid.vlaanderen.be/Webdiensten-Gebruiksrecht</dct:identifier>
          </dct:LicenseDocument>
        </dct:license>
      </content>
    </license>
  </xsl:variable>
</xsl:stylesheet>
