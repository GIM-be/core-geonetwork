<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                version="2.0">

  <xsl:template match="/root">
    <xsl:apply-templates select="*:MD_Metadata"/>
  </xsl:template>

  <!-- Only gmd:referenceSystemIdentifier can have a gmd:RS_Identifier child element, all other RS_Identifier elements
        must be transformed to a MD:Identifier and existing child elements gmd:codeSpace and gmd:version must be removed -->
  <xsl:template match="gmd:RS_Identifier[not(name(..)='gmd:referenceSystemIdentifier')]" priority="100">
    <gmd:MD_Identifier>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*[not(name(.)='gmd:codeSpace' or name(.)='gmd:version')]"/>
    </gmd:MD_Identifier>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
