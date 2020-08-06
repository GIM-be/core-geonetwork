<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
	xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >

	<xsl:output method="xml" indent="yes"/>
	
	<!-- Change elements-->	
	<xsl:template match="gmd:characterSet[name(..)=('gmd:MD_Metadata','gmd:MD_DataIdentification')]">">
		<xsl:call-template name="logAttributesAndValue">
			<xsl:with-param name="element" select="gmd:MD_CharacterSetCode"/>
		</xsl:call-template>
		<xsl:copy copy-namespaces="no">
			<gmd:MD_CharacterSetCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8">UTF-8</gmd:MD_CharacterSetCode>
		</xsl:copy>	
	</xsl:template>
</xsl:stylesheet>
