<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
	xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd" >

	<xsl:output method="xml" indent="yes"/>
	
	<!-- Convert time elements-->	
	<xsl:template match="gmd:dateStamp">
		<xsl:copy copy-namespaces="no">
			<xsl:choose>
				 <xsl:when test="gco:DateTime">
					 <xsl:call-template name="logAttributesAndValue">
						<xsl:with-param name="element" select="gco:DateTime" />
					</xsl:call-template>
					<xsl:message><xsl:value-of select="concat($logPrefix,' DateTime format... ')"/></xsl:message>
					<gco:Date><xsl:value-of  select="format-dateTime(.,'[Y0001]-[M01]-[D01]')"/></gco:Date>
				</xsl:when>
				<!-- match regex: regex ^and $ are not recognised by xslt. Use spaces instead -->
				<xsl:when test="matches(concat(' ',.,' '),'\s\d{1,2}\D\d{1,2}\D\d{4}\s')">
					<xsl:call-template name="logAttributesAndValue">
						<xsl:with-param name="element" select="gco:Date" />
					</xsl:call-template>
					<xsl:message><xsl:value-of select="concat($logPrefix,' Transforming date format DD/MM/YYYY...')"/></xsl:message>
					<gco:Date><xsl:value-of  select="replace(.,'(\d{1,2})\D(\d{1,2})\D(\d{4})','$3-$2-$1')"/></gco:Date>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message><xsl:value-of select="concat($logPrefix,'Date/Time Format ',*,' not recognised by system')"/></xsl:message>
					<xsl:apply-templates select="@*|node()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>	
	</xsl:template>
</xsl:stylesheet>
