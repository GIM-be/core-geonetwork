<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd">
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  <xsl:include href="agiv-add-keyword.xsl"/>

  <xsl:variable name="thesaurusTitleString">GDI-Vlaanderen Trefwoorden</xsl:variable>
  <xsl:variable name="thesaurusTitleAnchor">https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden</xsl:variable>
  <xsl:variable name="thesaurusDate">2014-02-26</xsl:variable>
  <xsl:variable name="keywordString">Metadata GDI-Vl-conform</xsl:variable>
  <xsl:variable name="keywordAnchor">https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/MDGDICONFORM</xsl:variable>

  <xsl:template match="/root">
    <xsl:apply-templates select="gmd:MD_Metadata"/>
  </xsl:template>

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
