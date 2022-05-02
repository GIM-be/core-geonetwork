<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                version="2.0" exclude-result-prefixes="#all">

  <xsl:variable name="titlePrefix">WMS: </xsl:variable>
  <xsl:variable name="titleSuffix"></xsl:variable>

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString" priority="1000">
    <gco:CharacterString><xsl:value-of select="concat($titlePrefix,.,$titleSuffix)"/></gco:CharacterString>
  </xsl:template>

  <!-- Copy all elements and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
