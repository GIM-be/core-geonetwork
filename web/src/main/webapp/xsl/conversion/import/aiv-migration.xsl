<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
  <xsl:include href="./aiv-scripts/aiv-convert-keywords-to-anchor.xsl"/>
  <xsl:include href="./aiv-scripts/aiv-minimal-update-fixed-info.xsl"/>
  <xsl:include href="aiv-scripts/aiv-remove-data-quality-info-optional-elements.xsl"/>

  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
