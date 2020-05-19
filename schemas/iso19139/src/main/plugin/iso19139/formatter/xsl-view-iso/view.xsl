<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:xslUtils="java:org.fao.geonet.util.XslUtil"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <!-- Some utility -->
  <!--<xsl:include href="../../layout/evaluate.xsl"/>-->
  <!--<xsl:include href="../../layout/utility-tpl-multilingual.xsl"/>-->
  <!--<xsl:include href="../../layout/utility-fn.xsl"/>-->

  <xsl:variable name="metadata"
                select="/root/gmd:MD_Metadata"/>

  <!--<xsl:variable name="langId" select="gn-fn-iso19139:getLangId($metadata, $language)"/>-->

  <xsl:template match="/">
    <div>
      <h2>
        <xsl:value-of
          select="string($metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString)"/>
      </h2>
      <p>(Work in progress)</p>
    </div>
  </xsl:template>
</xsl:stylesheet>
