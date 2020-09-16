<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >

	<xsl:output method="xml" indent="yes"/>

	<!-- Replace language-->
  <xsl:template match="gmd:language[name(..)=('gmd:MD_Metadata','gmd:MD_DataIdentification')]" priority="1000">
		<xsl:call-template name="logAttributesAndValue">
			<xsl:with-param name="element" select="gmd:LanguageCode"/>
		</xsl:call-template>
    <xsl:variable name="codeListValue" select="gmd:LanguageCode/@codeListValue" />
		<xsl:copy copy-namespaces="no">
      <xsl:variable name="languageCode">
        <xsl:choose>
          <xsl:when test="$codeListValue='dut'">Nederlands</xsl:when>
          <xsl:when test="$codeListValue='eng'">English</xsl:when>
          <xsl:otherwise><xsl:value-of select="gmd:LanguageCode"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
			<gmd:LanguageCode codeList="https://www.loc.gov/standards/iso639-2/" codeListValue="{$codeListValue}"><xsl:value-of select="$languageCode" /></gmd:LanguageCode>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
