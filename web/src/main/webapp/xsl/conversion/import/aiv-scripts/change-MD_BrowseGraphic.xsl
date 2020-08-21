<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >

	<xsl:output method="xml" indent="yes"/>

	<!-- Convert time elements-->
	<xsl:template match="gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString[contains(.,'metadata_thumbs')]">
		<xsl:copy copy-namespaces="no"><xsl:value-of select="concat('https://metadata.vlaanderen.be/metadata_thumbs',substring-after(.,'metadata_thumbs'))"/></xsl:copy>
	</xsl:template>
</xsl:stylesheet>
