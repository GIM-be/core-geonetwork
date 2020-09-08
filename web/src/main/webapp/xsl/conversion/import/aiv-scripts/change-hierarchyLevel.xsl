<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >

	<xsl:output method="xml" indent="yes"/>

	<!-- Remove gmd:hierarchyLevelName for gmd:MD_ScopeCode with codeListValue dataset, series and service -->
	<xsl:template match="gmd:hierarchyLevelName[lower-case(../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)=('dataset','series','service')]" priority="1000">
		<!--xsl:message><xsl:value-of select="concat($logPrefix,'Remove element gmd:hierarchyLevelName with value ',gco:CharacterString, ' (Already added based on value of gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue)')"/></xsl:message-->
	</xsl:template>

	<!-- Change gmd:hierarchyLevelName -->
	<xsl:template match="gmd:hierarchyLevel[lower-case(gmd:MD_ScopeCode/@codeListValue)=('dataset','series','service')]" priority="1000">
		<xsl:call-template name="logAttributesAndValue">
			<xsl:with-param name="element" select="gmd:MD_ScopeCode"/>
		</xsl:call-template>
		<xsl:copy copy-namespaces="no">
			<gmd:MD_ScopeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_ScopeCode" codeListValue="{lower-case(gmd:MD_ScopeCode/@codeListValue)}"/>
		</xsl:copy>
		<xsl:variable name="hierarchyLevelNameValue">
			<xsl:choose>
				<xsl:when test="lower-case(gmd:MD_ScopeCode/@codeListValue) = 'dataset'">Dataset</xsl:when>
				<xsl:when test="lower-case(gmd:MD_ScopeCode/@codeListValue) = 'series'">Datasetserie</xsl:when>
				<xsl:when test="lower-case(gmd:MD_ScopeCode/@codeListValue) = 'service'">Dienst</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:message><xsl:value-of select="concat($logPrefix,'Updating element gmd:hierarchyLevelName with value ',$hierarchyLevelNameValue)"/></xsl:message>
		<gmd:hierarchyLevelName>
			<gco:CharacterString><xsl:value-of select="$hierarchyLevelNameValue" /></gco:CharacterString>
		</gmd:hierarchyLevelName>
	</xsl:template>
</xsl:stylesheet>
