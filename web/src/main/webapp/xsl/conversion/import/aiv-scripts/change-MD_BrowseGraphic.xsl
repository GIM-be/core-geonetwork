<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >

	<xsl:output method="xml" indent="yes"/>

	<!-- Convert time elements-->
	<xsl:template match="gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString[contains(.,'metadata_thumbs')]" priority="1000">
		<xsl:copy copy-namespaces="no"><xsl:value-of select="concat('https://metadata.vlaanderen.be/metadata_thumbs',substring-after(.,'metadata_thumbs'))"/></xsl:copy>
	</xsl:template>

  <xsl:template match="gmd:MD_BrowseGraphic/gmd:fileDescription/gco:CharacterString[text() = ('thumbnail', 'thumbnail_large')]" priority="1000">
    <xsl:copy copy-namespaces="no">
      <xsl:choose>
        <xsl:when test="text() = 'thumbnail'">
          <xsl:value-of select="'Voorbeeldweergave'"/>
        </xsl:when>
        <xsl:when test="text() = 'thumbnail_large'">
          <xsl:value-of select="'Voorbeeldweergave (groot)'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="text()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString[contains(.,'resources.get')]" priority="1000">
    <xsl:copy copy-namespaces="no">
      <xsl:value-of select="concat('https://',if ($environment!='prod') then concat($environment,'.') else '','metadata.vlaanderen.be')"/><xsl:if test="$nodeType='Metadatacenter'">/metadatacenter</xsl:if><xsl:value-of select="concat('/srv/dut/resources.get', substring-after(.,'resources.get'))"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
