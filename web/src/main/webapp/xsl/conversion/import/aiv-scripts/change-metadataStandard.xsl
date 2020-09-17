<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >

	<xsl:output method="xml" indent="yes"/>
	<xsl:variable name="metadataStandardNameForDatasetAndSeries">ISO 19115/2003/Cor.1:2006/INSPIRE-TG2.0</xsl:variable>
	<xsl:variable name="metadataStandardVersion">GDI-Vlaanderen Best Practices - versie 2.0</xsl:variable>
	<!-- Change elements -->
	<xsl:template match="gmd:metadataStandardName[$nodeType='Metadatacenter' and lower-case(../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue) = ('series','dataset')]" priority="1000">
		<xsl:call-template name="logAttributesAndValue">
			<xsl:with-param name="element" select="gco:CharacterString"/>
		</xsl:call-template>
		<xsl:message><xsl:value-of select=" concat($logPrefix, 'Updating gmd:metadataStandardName for ',../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue,'')"/></xsl:message>
		<xsl:copy copy-namespaces="no">
			<gco:CharacterString><xsl:value-of select="$metadataStandardNameForDatasetAndSeries" /></gco:CharacterString>
		</xsl:copy>
		<xsl:if test="count(../gmd:metadataStandardVersion)=0">
			<xsl:message><xsl:value-of select=" concat($logPrefix, 'Adding missing gmd:metadataStandardVersion for ',../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue,'')"/></xsl:message>
			<gmd:metadataStandardVersion>
				<gco:CharacterString><xsl:value-of select="$metadataStandardVersion"/></gco:CharacterString>
			</gmd:metadataStandardVersion>
		</xsl:if>
	</xsl:template>

	<xsl:template match="gmd:metadataStandardVersion[$nodeType='Metadatacenter' and lower-case(../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue) = ('series','dataset')]" priority="1000">
		<xsl:call-template name="logAttributesAndValue">
			<xsl:with-param name="element" select="gco:CharacterString"/>
		</xsl:call-template>
		<xsl:if test="count(../gmd:metadataStandardName)=0">
			<xsl:message><xsl:value-of select=" concat($logPrefix, 'Adding missing gmd:metadataStandardName for ',../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue,'')"/></xsl:message>
			<gmd:metadataStandardName>
				<gco:CharacterString><xsl:value-of select="$metadataStandardNameForDatasetAndSeries" /></gco:CharacterString>
			</gmd:metadataStandardName>
		</xsl:if>
		<xsl:message><xsl:value-of select=" concat($logPrefix, 'Updating gmd:metadataStandardVersion for ',../gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue,'')"/></xsl:message>
		<xsl:copy copy-namespaces="no">
			<gco:CharacterString><xsl:value-of select="$metadataStandardVersion"/></gco:CharacterString>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
