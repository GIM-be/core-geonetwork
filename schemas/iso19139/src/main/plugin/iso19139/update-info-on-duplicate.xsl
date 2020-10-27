<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                version="2.0" exclude-result-prefixes="#all">

  <xsl:include href="../iso19139/convert/functions.xsl"/>
  <xsl:include href="update-fixed-info-keywords.xsl"/>
  <xsl:include href="layout/utility-fn.xsl"/>

  <xsl:variable name="serviceUrl" select="/root/env/siteURL"/>
  <xsl:variable name="node" select="/root/env/node"/>

  <!-- We use the category check to find out if this is an SDS metadata. Please replace with anything better -->
  <xsl:variable name="isSDS"
                select="count(//gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor[starts-with(@xlink:href, 'http://inspire.ec.europa.eu/metadata-codelist/Category')]) = 1"/>

  <!-- The default language is also added as gmd:locale for multilingual metadata records. -->
  <xsl:variable name="mainLanguage" select="/root/*/gmd:language/gco:CharacterString/text()| /root/*/gmd:language/gmd:LanguageCode/@codeListValue"/>
  <xsl:variable name="isMultilingual" select="count(/root/*/gmd:locale[*/gmd:languageCode/*/@codeListValue != $mainLanguage]) > 0"/>
  <xsl:variable name="mainLanguageId" select="upper-case(java:twoCharLangCode($mainLanguage))"/>
  <xsl:variable name="locales" select="/root/*/gmd:locale/gmd:PT_Locale"/>
  <xsl:variable name="defaultEncoding" select="'utf8'"/>
  <xsl:variable name="editorConfig" select="document('layout/config-editor.xml')"/>
  <xsl:variable name="nonMultilingualFields" select="$editorConfig/editor/multilingualFields/exclude"/>


  <xsl:template match="/root">
    <xsl:apply-templates select="*:MD_Metadata"/>
  </xsl:template>

  <!-- Empty titles string -->
  <xsl:template match="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
    <gmd:title gco:nilReason="missing">
      <gco:CharacterString/>
    </gmd:title>
  </xsl:template>

  <xsl:template match="gmd:identificationInfo/*/gmd:citation/*/gmd:alternateTitle">
    <gmd:alternateTitle gco:nilReason="missing">
      <gco:CharacterString/>
    </gmd:alternateTitle>
  </xsl:template>

  <xsl:template match="gmd:parentIdentifier">
    <gmd:parentIdentifier gco:nilReason="missing">
      <gco:CharacterString/>
    </gmd:parentIdentifier>
  </xsl:template>

  <!-- Set a new RS_Identifier or gmd:MD_Identifier -->
  <xsl:template match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:RS_Identifier|
                       gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <gmd:code>
        <gco:CharacterString>
          <xsl:value-of select="/root/env/mduuid"/>
        </gco:CharacterString>
      </gmd:code>
      <xsl:if test="name() = 'gmd:RS_Identifier'">
        <gmd:codeSpace gco:nilReason="missing">
          <gco:CharacterString/>
        </gmd:codeSpace>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- Reinitialize feature catalogue description -->
  <xsl:template match="gmd:MD_FeatureCatalogueDescription">
    <gmd:MD_FeatureCatalogueDescription>
      <gmd:includedWithDataset>
        <gco:Boolean>true</gco:Boolean>
      </gmd:includedWithDataset>
      <gmd:featureCatalogueCitation uuidref=""/>
    </gmd:MD_FeatureCatalogueDescription>
  </xsl:template>

  <!-- copy everything else as is -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
