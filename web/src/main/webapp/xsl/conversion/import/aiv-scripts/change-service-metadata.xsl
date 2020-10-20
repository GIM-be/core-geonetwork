<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:srv="http://www.isotc211.org/2005/srv">

	<xsl:output method="xml" indent="yes"/>

  <xsl:template match="srv:couplingType [$nodeType='Geopunt']" priority="1000">
    <srv:couplingType><srv:SV_CouplingType codeList="https://standards.iso.org/iso/19115/resources/Codelists/gml/SV_CouplingType.xml" codeListValue="tight" /></srv:couplingType>
  </xsl:template>

  <xsl:template match="srv:serviceType/gco:LocalName[$nodeType='Geopunt']" priority="1000">
    <xsl:variable name="localName">
      <xsl:choose>
        <xsl:when test=".='view en download'">view</xsl:when>
        <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <gco:LocalName codeSpace="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceType"><xsl:value-of select="$localName"/></gco:LocalName>
  </xsl:template>

  <xsl:template match="srv:serviceTypeVersion[$nodeType='Geopunt']" priority="1000"/>

  <xsl:template match="srv:operatesOn[$nodeType='Geopunt']" priority="1000">
    <xsl:if test="@xlink:href!=''">
      <srv:operatesOn xlink:href="{concat('https://',if ($environment!='prod') then concat($environment,'.') else '','metadata.vlaanderen.be/srv/dut/csw',substring-after(@xlink:href,'csw'))}" uuidref="{@uuidref}" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
