<?xml version="1.0" encoding="UTF-8"?>
<!--
 this stylesheet removes keywords marking INSPIRE conformance.

 If the descriptiveKeywords element does not contain such a keyword, it is just put out.
 If it does, it is put out retaining all its other keywords (but not the ISNPIRE conformance marker keyword).
 If the INSPIRE conformance marker is the only keyword in this descriptiveKeywords element, it is entirely removed.
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd">
  <xsl:output method="xml" indent="yes" encoding="utf-8"/>
  <xsl:include href="agiv-remove-keyword.xsl"/>

  <xsl:variable name="thesaurusTitle">GDI-Vlaanderen Trefwoorden</xsl:variable>
  <xsl:variable name="keywordToBeRemovedLowerCase">metadata gdi-vl-conform</xsl:variable>

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
