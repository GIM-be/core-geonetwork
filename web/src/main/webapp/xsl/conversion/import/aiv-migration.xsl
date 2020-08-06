<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">
  <xsl:output method="xml" indent="no" encoding="utf-8"/>
  <xsl:include href="aiv-scripts/aiv-convert-keywords-to-anchor.xsl"/>
  <xsl:include href="aiv-scripts/aiv-minimal-update-fixed-info.xsl"/>
  <xsl:include href="aiv-scripts/aiv-remove-data-quality-info-optional-elements.xsl"/>
  <xsl:include href="aiv-scripts/change-LanguageCode.xsl"/>
  <xsl:include href="aiv-scripts/change-MD_CharacterSetCode.xsl"/>
  <xsl:include href="aiv-scripts/change-metadataStandard.xsl"/>
  <xsl:include href="aiv-scripts/change-dateStamp-format.xsl"/>
  <xsl:include href="aiv-scripts/change-referenceSystemInfo.xsl"/>
  <xsl:include href="aiv-scripts/change-hierarchyLevel.xsl"/>
  <xsl:variable name="logPrefix">XSL LOG: </xsl:variable>

  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- LOG fileidentifier-->
  <xsl:template match="gmd:fileIdentifier/gco:CharacterString">
    <xsl:call-template name="logAttributesAndValue" />
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|*"/>
    </xsl:copy>
  </xsl:template>

  <!-- Log the attributes and the value of an XML element -->
  <xsl:template name="logAttributesAndValue">
    <xsl:param name="element" select="."/>
    <xsl:message>
      <xsl:value-of select="concat($logPrefix, '---------------------------------------', '&#xa;')"/>
      <xsl:value-of select="concat($logPrefix, 'Logging element ', $element/name(..), '/', $element/name(), '&#xa;')"/>
      <xsl:for-each select="$element/@*">
        <xsl:value-of select="concat($logPrefix, 'Attribute: &quot;', name(), '&quot; has value: ', ., '&#xa;')"/>
      </xsl:for-each>
      <xsl:value-of select="concat($logPrefix, 'The element has value: ', $element)"/>
    </xsl:message>
  </xsl:template>

</xsl:stylesheet>
