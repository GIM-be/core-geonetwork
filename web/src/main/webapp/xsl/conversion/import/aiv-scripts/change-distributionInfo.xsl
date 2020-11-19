<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:gmd="http://www.isotc211.org/2005/gmd">

	<xsl:output method="xml" indent="yes"/>
  <!--xsl:variable name="hierarchyLevel" select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/-->

	<!-- Change elements-->
  <!--xsl:template match="gmd:onLine[$nodeType='Metadatacenter' and $hierarchyLevel!='service' and name(..)='gmd:MD_DigitalTransferOptions']" priority="1000"-->
  <xsl:template match="gmd:onLine[$nodeType='Metadatacenter' and name(..)='gmd:MD_DigitalTransferOptions']" priority="1000">
    <xsl:variable name="protocol" select="gmd:CI_OnlineResource/gmd:protocol/*/normalize-space(text())"/>
    <xsl:choose>
      <xsl:when test="$protocol='OGC:WMS'"/>
      <xsl:when test="$protocol='OGC:WMS-1.1.1-http-get-featureinfo'"/>
      <xsl:when test="$protocol='OGC:WMS-1.3.0-http-get-featureinfo'"/>
      <xsl:when test="$protocol='OGC:WFS'"/>
      <xsl:when test="$protocol='OGC:WFS-1.0.0-http-describefeaturetype'"/>
      <xsl:when test="$protocol='OGC:WFS-1.1.0-http-describefeaturetype'"/>
      <xsl:when test="$protocol='OGC:WFS-1.1.0-http-getgmlobject'"/>
      <xsl:when test="$protocol='OGC:WFS-2.0.0-http-describefeaturetype'"/>
      <xsl:when test="$protocol='OGC:WCS'"/>
      <xsl:when test="$protocol='OGC:WMTS'"/>
      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
	</xsl:template>

  <!--xsl:template match="gmd:onLine[$nodeType='Metadatacenter' and $hierarchyLevel='service' and name(..)='gmd:MD_DigitalTransferOptions']" priority="1000">
    <xsl:variable name="protocol" select="gmd:CI_OnlineResource/gmd:protocol/*/normalize-space(text())"/>
    <xsl:choose>
      <xsl:when test="$protocol='OGC:WMS'"/>
      <xsl:when test="$protocol='OGC:WMS-1.1.1-http-get-map'"/>
      <xsl:when test="$protocol='OGC:WMS-1.1.1-http-get-featureinfo'"/>
      <xsl:when test="$protocol='OGC:WMS-1.3.0-http-get-map'"/>
      <xsl:when test="$protocol='OGC:WMS-1.3.0-http-get-featureinfo'"/>
      <xsl:when test="$protocol='OGC:WFS'"/>
      <xsl:when test="$protocol='OGC:WFS-1.0.0-http-get-feature'"/>
      <xsl:when test="$protocol='OGC:WFS-1.0.0-http-describefeaturetype'"/>
      <xsl:when test="$protocol='OGC:WFS-1.1.0-http-get-feature'"/>
      <xsl:when test="$protocol='OGC:WFS-1.1.0-http-describefeaturetype'"/>
      <xsl:when test="$protocol='OGC:WFS-1.1.0-http-getgmlobject'"/>
      <xsl:when test="$protocol='OGC:WFS-2.0.0-http-get-feature'"/>
      <xsl:when test="$protocol='OGC:WFS-2.0.0-http-describefeaturetype'"/>
      <xsl:when test="$protocol='OGC:WCS'"/>
      <xsl:when test="$protocol='OGC:WCS-1.1.1-http-get-coverage'"/>
      <xsl:when test="$protocol='OGC:WMTS'"/>
      <xsl:when test="$protocol='OGC:WMTS-1.0.0-http-get-tile'"/>
      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template-->

  <xsl:template match="gmd:protocol" priority="1000">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="protocol" select="*/normalize-space(text())"/>
      <xsl:message select="concat('Handling protocol ',$protocol)" />
      <xsl:variable name="mappedProtocol">
        <xsl:call-template name="mapProtocol">
          <xsl:with-param name="protocol" select="$protocol"/>
        </xsl:call-template>
      </xsl:variable>
      <gco:CharacterString><xsl:value-of select="$mappedProtocol"/></gco:CharacterString>
      <xsl:message select="concat('The gco:CharacterString protocol ',$protocol,' is mapped to ', $mappedProtocol)" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="mapProtocol">
    <xsl:param name="protocol"/>
    <xsl:choose>
      <xsl:when test="$protocol='Bestand ter download dmv HTTP (WWW:DOWNLOAD-1.0-http--download)'">WWW:DOWNLOAD-1.0-http--download</xsl:when>
      <xsl:when test="$protocol='(WWW:LINK-1.0-http--link)'">WWW:LINK-1.0-http--related</xsl:when>
      <!-- Remove some invisible character at the end, in normalize-space is not removing it -->
      <xsl:when test="$protocol='WWW:LINK-1.0-http--link '">WWW:LINK-1.0-http--link</xsl:when>
      <xsl:otherwise><xsl:value-of select="$protocol"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
