<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gfc="http://www.isotc211.org/2005/gfc"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                version="2.0">
  <xsl:variable name="formatter" select="'default'"/>
  <xsl:variable name="schema" select="/root/info/record/datainfo/schemaid"/>
  <xsl:variable name="source" select="/root/info/record/sourceinfo/sourceid"/>
  <xsl:variable name="metadataId" select="/root/info/record/id"/>
  <xsl:variable name="metadataUuid" select="/root/info/record/uuid"/>
  <xsl:variable name="language" select="/root/lang/text()"/>
  <xsl:variable name="nodeUrl" select="/root/gui/nodeUrl"/>
  <xsl:variable name="schemaStrings" select="/root/schemas/*[name() = $schema]/strings"/>
  <xsl:variable name="schemaCodeLists" select="/root/schemas/*[name() = $schema]/codelists"/>

  <xsl:variable name="dateFormats">
    <dateTime>
      <for lang="eng" default="true">[H1]:[m01]:[s01] on [D1] [MNn] [Y]</for>
      <for lang="fre">[H1]:[m01]:[s01] le [D1] [MNn] [Y]</for>
    </dateTime>
    <date>
      <for lang="eng" default="true">[D1] [MNn] [Y]</for>
      <for lang="fre">[D1] [MNn] [Y]</for>
    </date>
  </xsl:variable>
  <xsl:variable name="metadata"
                select="/root/(gfc:FC_FeatureType|gfc:FC_FeatureCatalogue)"/>
  <xsl:variable name="schemaLoc" select="tr:create($schema)"/>
</xsl:stylesheet>
