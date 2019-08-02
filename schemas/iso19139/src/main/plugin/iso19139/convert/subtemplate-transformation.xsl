<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!--
    Define here templates configured in the attribute "transformation" of
    the entry selector directive declared in the config editor.
    Templates will be applied just before appending a subtemplate to a
    metadata.
  -->

  <xsl:template name="removeRoot">
    <xsl:copy-of select="./*"/>
  </xsl:template>

</xsl:stylesheet>
