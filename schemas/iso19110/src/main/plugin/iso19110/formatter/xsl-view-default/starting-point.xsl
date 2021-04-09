<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gfc="http://www.isotc211.org/2005/gfc"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0">

  <xsl:output method="html"/>

  <xsl:param name="root" select="'html'"/>
  <xsl:param name="template" select="''"/>
  <xsl:param name="output"/>

  <xsl:include href="common/render-html.xsl"/>
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$output = ('pdf', 'html')">
        <xsl:call-template name="render-pdf">
          <xsl:with-param name="content">
            <xsl:call-template name="render-record">
              <xsl:with-param name="fullWidth" select="true()"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="title">
            <xsl:apply-templates mode="getMetadataTitle" select="$metadata"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$root = 'div'">
        <xsl:call-template name="render-record"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="render-html">
          <xsl:with-param name="content">
            <xsl:call-template name="render-record"/>
          </xsl:with-param>
          <xsl:with-param name="title">
            <xsl:apply-templates mode="getMetadataTitle" select="$metadata"/>
          </xsl:with-param>
          <xsl:with-param name="description">
            <xsl:apply-templates mode="getMetadataAbstract" select="$metadata"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="render-record">
    <xsl:param name="fullWidth" select="false()"/>
    <div class="container-fluid gn-metadata-view gn-schema-{$schema}">
      <xsl:variable name="title">
        <xsl:apply-templates mode="getMetadataTitle" select="$metadata"/>
      </xsl:variable>
      <article id="{$metadataUuid}"
               class="gn-md-view gn-metadata-display aiv-gp-view">
        <div class="row">
          <div class="{if ($fullWidth) then 'col-md-12' else 'col-md-8'}">
            <header>
              <h1>
                <xsl:value-of select="$title"/>
              </h1>
              <xsl:apply-templates mode="getMetadataHeader" select="$metadata"/>
            </header>
            <div class="tab-content">
              <!-- Templates defined in the file view.xsl -->
              <xsl:apply-templates mode="render-content" select="$metadata"/>
            </div>
          </div>
        </div>
      </article>
      <br/>
      <br/>
    </div>
  </xsl:template>

  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="gfc:FC_FeatureType|gfc:FC_FeatureCatalogue">
    <xsl:variable name="value"
                  select="gmx:name"/>
    <xsl:value-of select="$value/gco:CharacterString"/>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="gfc:FC_FeatureType|gfc:FC_FeatureCatalogue">
    <xsl:variable name="value"
                  select="gmx:scope"/>
    <xsl:value-of select="$value/gco:CharacterString"/>
  </xsl:template>

  <xsl:template mode="getMetadataHeader" match="gfc:FC_FeatureType|gfc:FC_FeatureCatalogue">
  </xsl:template>

</xsl:stylesheet>
