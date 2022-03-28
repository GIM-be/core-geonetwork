<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:void="http://www.w3.org/TR/void/"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <xsl:output indent="yes"/>

  <xsl:include href="../../common/base-variables.xsl"/>
  <xsl:include href="../../common/profiles-loader-tpl-rdf.xsl"/>

  <xsl:variable name="serviceUrl" select="/root/env/siteURL"/>
  <xsl:variable name="iso2letterLanguageCode" select="lower-case(java:twoCharLangCode(/root/gui/language))"/>
  <xsl:variable name="resourcePrefix" select="$env/metadata/resourceIdentifierPrefix"/>

  <xsl:template match="/">
    <rdf:RDF>

      <xsl:call-template name="add-namespace"/>

      <!-- Metadata element -->
      <xsl:call-template name="catalogue"/>

      <xsl:apply-templates mode="to-dcat" select="/root/*|/root/search/response/*"/>

      <!--  <xsl:apply-templates mode="references" select="/root/*|/root/search/response/*"/> -->
    </rdf:RDF>

  </xsl:template>

  <xsl:template name="add-namespace">
    <xsl:namespace name="rdf" select="'http://www.w3.org/1999/02/22-rdf-syntax-ns#'"/>
    <xsl:namespace name="skos" select="'http://www.w3.org/2004/02/skos/core#'"/>
    <xsl:namespace name="spdx" select="'http://spdx.org/rdf/terms#'"/>
    <xsl:namespace name="owl" select="'http://www.w3.org/2002/07/owl#'"/>
    <xsl:namespace name="adms" select="'http://www.w3.org/ns/adms#'"/>
    <xsl:namespace name="locn" select="'http://www.w3.org/ns/locn#'"/>
    <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
    <xsl:namespace name="foaf" select="'http://xmlns.com/foaf/0.1/'"/>
    <xsl:namespace name="dct" select="'http://purl.org/dc/terms/'"/>
    <xsl:namespace name="vcard" select="'http://www.w3.org/2006/vcard/ns#'"/>
    <xsl:namespace name="dcat" select="'http://www.w3.org/ns/dcat#'"/>
    <xsl:namespace name="schema" select="'http://schema.org/'"/>
    <xsl:namespace name="dc" select="'http://purl.org/dc/elements/1.1/'"/>
    <xsl:namespace name="vlgen" select="'https://data.vlaanderen.be/ns/generiek'"/>
  </xsl:template>


  <xsl:template name="catalogue">


    <!-- First, the local catalog description using dcat:Catalog.
      "Typically, a web-based data catalog is represented as a single instance of this class."
      ... also describe harvested catalogues if harvested records are in the current dump.
    -->
    <dcat:Catalog rdf:about="{$resourcePrefix}/catalogs/{$env/system/site/siteId}">

      <!-- A name given to the catalog. -->
      <dct:title xml:lang="{$iso2letterLanguageCode}">
        <xsl:value-of select="$env/system/site/name"/>
      </dct:title>

      <!-- free-text account of the catalog. -->
      <dct:description xml:lang="{$iso2letterLanguageCode}">
        <xsl:value-of select="concat($env/system/site/name, ' (', $env/system/site/organization, ')')"/>
      </dct:description>

      <!-- Unique identifier of the catalog -->
      <dct:identifier>
        <xsl:value-of select="$env/system/site/siteId"/>
      </dct:identifier>

      <!-- The entity responsible for making the catalog online. -->
      <dct:publisher>
    	<!-- Organization in charge of the catalogue defined in the administration > system configuration -->
	    <foaf:Agent rdf:about="{$resourcePrefix}/organizations/{encode-for-uri($env/system/site/organization)}">
	      <foaf:name xml:lang="{$iso2letterLanguageCode}">
	        <xsl:value-of select="$env/system/site/organization"/>
	      </foaf:name>
	    </foaf:Agent>
      </dct:publisher>

      <!-- The homepage of the catalog -->
      <foaf:homepage>
        <foaf:Document>
          <xsl:if test="normalize-space($serviceUrl) != ''">
            <xsl:attribute name="rdf:about" select="$serviceUrl"/>
          </xsl:if>
          <foaf:name xml:lang="{$iso2letterLanguageCode}"><xsl:value-of select="$env/system/site/name"/></foaf:name>
        </foaf:Document>
      </foaf:homepage>

      <!-- The license of the catalog -->
      <dct:license>
        <dct:LicenseDocument rdf:about="https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0">
          <dct:type>
            <skos:Concept rdf:about="http://purl.org/adms/licencetype/PublicDomain">
              <skos:prefLabel xml:lang="nl">Werk in het publiek domein</skos:prefLabel>
              <skos:prefLabel xml:lang="en">Public domain</skos:prefLabel>
              <skos:prefLabel xml:lang="fr">Public domain</skos:prefLabel>
              <skos:prefLabel xml:lang="de">Public domain</skos:prefLabel>
              <skos:inScheme rdf:resource="http://purl.org/adms/licencetype/1.0" />
            </skos:Concept>
          </dct:type>
          <dct:title xml:lang="nl">Creative Commons Zero verklaring</dct:title>
          <dct:description xml:lang="nl">De instantie doet afstand van haar intellectuele eigendomsrechten voor zover dit wettelijk mogelijk is. Hierdoor kan de gebruiker de data hergebruiken voor eender welk doel, zonder een verplichting op naamsvermelding. Deze is de welbekende CC0 licentie.</dct:description>
          <dct:identifier>https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0</dct:identifier>
        </dct:LicenseDocument>
      </dct:license>
      <dcat:contactPoint>
        <vcard:Organization>
          <vcard:organization-name>
            <xsl:value-of select="$env/system/site/organization"/>
          </vcard:organization-name>
          <vcard:hasEmail rdf:resource="mailto:digitaal.vlaanderen@vlaanderen.be" />
          <vcard:hasURL rdf:resource="https://www.vlaanderen.be/digitaal-vlaanderen" />
        </vcard:Organization>
      </dcat:contactPoint>

      <xsl:if test="normalize-space(/root/request/uuid[1]) != ''">
        <xsl:apply-templates mode="record-reference" select="/root/*"/>
      </xsl:if>
    </dcat:Catalog>
  </xsl:template>


  <!-- Avoid request and gui tag in template modes related to metadata conversion -->
  <xsl:template mode="record-reference" match="gui|request|metadata|translations|search|summary"/>

  <xsl:template mode="to-dcat" match="gui|request|metadata|translations|search|summary"/>

  <xsl:template mode="references" match="gui|request|metadata|translations|search|summary"/>

</xsl:stylesheet>
