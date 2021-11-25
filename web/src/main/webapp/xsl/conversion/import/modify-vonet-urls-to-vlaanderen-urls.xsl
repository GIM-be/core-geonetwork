<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0" exclude-result-prefixes="#all">

  <xsl:variable name="urlPartToUpdate">omgeving.vonet.be</xsl:variable>
  <xsl:variable name="newUrlPart">omgeving.vlaanderen.be</xsl:variable>

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:featureCatalogueCitation/@xlink:href[contains(.,$urlPartToUpdate)]|
    srv:operatesOn/@xlink:href[contains(.,$urlPartToUpdate)]|
    gmd:identifier/gmd:MD_Identifier/gmd:code/gmx:Anchor/@xlink:href[contains(.,$urlPartToUpdate)]" priority="1000">
      <xsl:attribute name="xlink:href" select="replace(.,$urlPartToUpdate,$newUrlPart)"/>
  </xsl:template>

  <!-- Copy all elements and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
