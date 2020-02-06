<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco">

  <!--
    Define here templates configured in the attribute "transformation" of
    the entry selector directive declared in the config editor.
    Templates will be applied just before appending a subtemplate to a
    metadata.
  -->

  <xsl:template name="removeRoot">
    <xsl:copy-of select="./*"/>
  </xsl:template>

  <xsl:template name="rsrcConstrTransform">
    <xsl:copy-of select="./*[not(name() = 'subtemplate-title')]"/>
  </xsl:template>

  <xsl:template name="otherConstrTransform">
    <xsl:apply-templates select="./*[not(name() = 'subtemplate-title')]" mode="normalise-spaces"/>
  </xsl:template>

  <xsl:template name="referenceSystemInfoTransform">
    <xsl:copy-of select="./*[not(name() = 'subtemplate-title')]"/>
  </xsl:template>

  <xsl:template match="@*|node()" mode="normalise-spaces">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="name() = 'gco:CharacterString' or name() = 'gmx:Anchor'">
          <xsl:copy-of select="@*"/>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
