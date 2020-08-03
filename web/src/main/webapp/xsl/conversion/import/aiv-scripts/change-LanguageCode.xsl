<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
	xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >

	<xsl:output method="xml" indent="yes"/>
	
	<!-- Replace language-->	
	<xsl:template match="gmd:language[name(..)=('gmd:MD_Metadata','gmd:MD_DataIdentification')]">
		<xsl:call-template name="logAttributesAndValue">
			<xsl:with-param name="element" select="gmd:LanguageCode"/>
		</xsl:call-template>
		<xsl:copy copy-namespaces="no">
			<gmd:LanguageCode codeList="https://www.loc.gov/standards/iso639-2/" codeListValue="dut">Nederlands</gmd:LanguageCode>
		</xsl:copy>	
	</xsl:template>

</xsl:stylesheet>
