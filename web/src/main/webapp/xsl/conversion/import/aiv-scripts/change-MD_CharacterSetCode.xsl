<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >

	<xsl:output method="xml" indent="yes"/>

	<!-- Change elements-->
  <xsl:template match="gmd:characterSet[name(..)=('gmd:MD_Metadata','gmd:MD_DataIdentification')]" priority="1000">
		<xsl:call-template name="logAttributesAndValue">
			<xsl:with-param name="element" select="gmd:MD_CharacterSetCode"/>
		</xsl:call-template>
    <xsl:variable name="currentCodeListValue" select="lower-case(gmd:MD_CharacterSetCode/@codeListValue)" />
		<xsl:copy copy-namespaces="no">
      <xsl:variable name="newCodeListValue">
        <xsl:choose>
          <xsl:when test="$currentCodeListValue=('utf8','md_charactersetcode_utf8')">utf8</xsl:when>
          <xsl:when test="$currentCodeListValue='8859part1'">8859part1</xsl:when>
          <xsl:otherwise><xsl:value-of select="gmd:MD_CharacterSetCode/@codeListValue"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="characterSetCode">
        <xsl:choose>
          <xsl:when test="$currentCodeListValue=('utf8','md_charactersetcode_utf8')">UTF-8</xsl:when>
          <xsl:when test="$currentCodeListValue='8859part1'">Latin-1</xsl:when>
          <xsl:otherwise><xsl:value-of select="gmd:MD_CharacterSetCode"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <gmd:MD_CharacterSetCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="{$newCodeListValue}"><xsl:value-of select="$characterSetCode" /></gmd:MD_CharacterSetCode>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
