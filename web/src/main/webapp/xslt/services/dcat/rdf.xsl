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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:saxon="http://saxon.sf.net/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:void="http://www.w3.org/TR/void/"
                xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:dct="http://purl.org/dc/terms/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                version="2.0"
                extension-element-prefixes="saxon" exclude-result-prefixes="#all">

  <xsl:output indent="yes"/>

  <xsl:include href="../../common/base-variables.xsl"/>
  <xsl:include href="../../common/profiles-loader-tpl-rdf.xsl"/>

  <xsl:variable name="serviceUrl" select="/root/env/siteURL"/>
  <xsl:variable name="iso2letterLanguageCode" select="lower-case(java:twoCharLangCode(/root/gui/language))"/>
  <xsl:variable name="resourcePrefix" select="$env/metadata/resourceIdentifierPrefix"/>

  <xsl:template match="/">
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
             xmlns:foaf="http://xmlns.com/foaf/0.1/"
             xmlns:void="http://www.w3.org/TR/void/" xmlns:dcat="http://www.w3.org/ns/dcat#"
             xmlns:dct="http://purl.org/dc/terms/"
             xmlns:skos="http://www.w3.org/2004/02/skos/core#">
      <!-- Metadata element -->

      <xsl:call-template name="catalogue"/>

      <xsl:apply-templates mode="to-dcat" select="/root/*|/root/search/response/*"/>

      <!--  <xsl:apply-templates mode="references" select="/root/*|/root/search/response/*"/> -->
    </rdf:RDF>

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

      <!-- The language of the catalog  -->
      <dct:language>
        <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/NLD">
          <rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
          <skos:prefLabel xml:lang="nl">Nederlands</skos:prefLabel>
          <skos:prefLabel xml:lang="en">Dutch</skos:prefLabel>
          <skos:prefLabel xml:lang="fr">néerlandais</skos:prefLabel>
          <skos:prefLabel xml:lang="de">Niederländisch</skos:prefLabel>
          <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
        </skos:Concept>
      </dct:language>


      <!-- free-text account of the catalog. -->
      <dct:description xml:lang="{$iso2letterLanguageCode}">
        <xsl:value-of select="$env/system/site/name"/> (<xsl:value-of
        select="$env/system/site/organization"/>)
      </dct:description>

      <!-- The entity responsible for making the catalog online. -->
      <dct:publisher>
    	<!-- Organization in charge of the catalogue defined in the administration > system configuration -->
	    <foaf:Agent rdf:about="{$resourcePrefix}/organizations/{encode-for-uri($env/system/site/organization)}">
	      <foaf:name xml:lang="{$iso2letterLanguageCode}">
	        <xsl:value-of select="$env/system/site/organization"></xsl:value-of>
	      </foaf:name>
	    </foaf:Agent>
      </dct:publisher>

      <!-- The homepage of the catalog -->
      <foaf:homepage>
			<foaf:Document rdf:about="{$serviceUrl}">
				<foaf:name xml:lang="{$iso2letterLanguageCode}"><xsl:value-of select="$env/system/site/name"/></foaf:name>
			</foaf:Document>
      </foaf:homepage>

      <!-- The license of the catalog -->
      <dct:license>
        <dct:LicenseDocument rdf:about="https://data.vlaanderen.be/id/licentie/creative-commons-zero-verklaring/v1.0">
          <dct:type>
            <skos:Concept rdf:about="http://purl.org/adms/licencetype/PublicDomain">
              <skos:prefLabel xml:lang="nl">Public domain</skos:prefLabel>
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

      <dct:issued>
        <xsl:attribute name="rdf:datatype" select="'http://www.w3.org/2001/XMLSchema#date'"/>
        <xsl:value-of select="'2019-09-01'"/>
      </dct:issued>
      <dct:modified>
        <xsl:attribute name="rdf:datatype" select="'http://www.w3.org/2001/XMLSchema#date'"/>
        <xsl:value-of select="'2019-09-01'"/>
      </dct:modified>

      <!--
      <void:openSearchDescription><xsl:value-of select="/root/gui/nodeUrl"/>eng/portal.opensearch</void:openSearchDescription>
      <void:uriLookupEndpoint><xsl:value-of select="/root/gui/nodeUrl"/>eng/rdf.search?any=</void:uriLookupEndpoint>
	  -->

      <!-- The knowledge organization system (KOS) used to classify catalog's datasets.
      -->
      <xsl:for-each select="/root/gui/thesaurus/thesauri/thesaurus">
        <dcat:themeTaxonomy>
	    <!-- ConceptScheme describes all thesaurus available in the catalogue
	      * Resource identifier is a local identifier for local thesaurus or public URI if external
	    -->
		      <skos:ConceptScheme rdf:about="{$resourcePrefix}/registries/vocabularies/{key}">
		        <dct:title xml:lang="{$iso2letterLanguageCode}">
		          <xsl:value-of select="title"/>
		        </dct:title>
		        <foaf:isPrimaryTopicOf><xsl:value-of select="$serviceUrl"/>thesaurus.download?ref=<xsl:value-of
		          select="key"/>
		        </foaf:isPrimaryTopicOf>
		      </skos:ConceptScheme>
        </dcat:themeTaxonomy>
      </xsl:for-each>


      <!-- The language of the catalog. This refers to the language used
        in the textual metadata describing titles, descriptions, etc.
        of the datasets in the catalog.

        http://www.ietf.org/rfc/rfc3066.txt

        Multiple values can be used. The publisher might also choose to describe
        the language on the dataset level (see dataset language).

      <dct:language>
			<skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/{/root/gui/language}">
				<rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
				<skos:prefLabel xml:lang="{$iso2letterLanguageCode}"><xsl:value-of select="/root/gui/language"/></skos:prefLabel>
				<skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
			</skos:Concept>
      </dct:language>
      -->


      <!-- This describes the license under which the catalog can be used/reused and not the datasets.
        Even if the license of the catalog applies to all of its datasets it should be
        replicated on each dataset.-->

      <!-- TODO using VoIDx
      <dct:license>
      </dct:license>
      -->


      <!-- The geographical area covered by the catalog.
      <dct:location>
       </dct:location> -->

      <!-- List all catalogue records
        <dcat:dataset rdf:resource="http://localhost:8080/geonetwork/dataset/1"/>
        <dcat:record rdf:resource="http://localhost:8080/geonetwork/metadata/1"/>

      <xsl:apply-templates mode="record-reference" select="/root/*|/root/search/response/*"/>
      -->

    </dcat:Catalog>



  </xsl:template>


  <!-- Avoid request and gui tag in template modes related to metadata conversion -->
  <xsl:template mode="record-reference" match="gui|request|metadata|translations|search|summary"/>

  <xsl:template mode="to-dcat" match="gui|request|metadata|translations|search|summary"/>

  <xsl:template mode="references" match="gui|request|metadata|translations|search|summary"/>

  <xsl:template mode="record-reference" match="metadata" priority="2">
    <dcat:dataset rdf:resource="{$resourcePrefix}/datasets/{geonet:info/uuid}"/>
    <!--   <dcat:record rdf:resource="{$resourcePrefix}/records/{geonet:info/uuid}"/> -->
  </xsl:template>


</xsl:stylesheet>
