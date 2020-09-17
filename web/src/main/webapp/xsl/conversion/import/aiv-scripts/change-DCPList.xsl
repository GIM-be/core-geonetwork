<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:srv="http://www.isotc211.org/2005/srv" >

	<xsl:output method="xml" indent="yes"/>

  <xsl:template match="srv:DCPList[@codeListValue='HTTPPost' and count(../../srv:DCP/srv:DCPList[@codeListValue=('HTTPGet','httpGet')])>0]" priority="2000"/>

	<!-- Change elements-->
  <xsl:template match="srv:DCPList" priority="1000">
		<xsl:call-template name="logAttributesAndValue"/>
    <xsl:variable name="codeListValue">
      <xsl:choose>
        <xsl:when test="@codeListValue=('HTTPGet','HTTPPost','httpGet')">HTTP</xsl:when>
        <xsl:when test="@codeListValue='HTTPSoap'">SOAP</xsl:when>
        <xsl:otherwise><xsl:value-of select="@codeListValue"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <srv:DCPList codeList="https://standards.iso.org/iso/19115/resources/Codelists/gml/DCPList.xml" codeListValue="{$codeListValue}"/>
	</xsl:template>
</xsl:stylesheet>
