<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <xsl:param name="output"/>
  <xsl:include href="../xsl-view-default/min-utility-fn.xsl"/>
  <xsl:include href="../xsl-view-default/variables.xsl"/>
  <xsl:include href="../xsl-view-default/common.xsl"/>
  <xsl:include href="sharedFormatterDir/xslt/render-functions.xsl"/>

  <xsl:template match="/">
    <xsl:call-template name="render-record"/>
  </xsl:template>


  <xsl:template name="render-record">
    <div class="container-fluid gn-metadata-view gn-schema-{$schema}">
      <xsl:variable name="title">
        <xsl:apply-templates mode="getMetadataTitle" select="$metadata"/>
      </xsl:variable>
      <article id="{$metadataUuid}"
               class="gn-md-view gn-metadata-display aiv-gp-view">
        <div class="row">
          <div class="col-md-8">
            <header>
              <h1>
                <i class="fa gn-icon-{{{{md.type[0]}}}}">
                  <xsl:comment select="'icon'"/>
                </i>
                <xsl:value-of select="$title"/>
              </h1>
              <xsl:apply-templates mode="getMetadataHeader" select="$metadata"/>
            </header>
            <div class="tab-content">
              <xsl:call-template name="render-block">
                <xsl:with-param name="header" select="gn-fn-iso19139:get-schema-strings($schemaStrings, 'mdLegalConstraintsSection')"/>
                <xsl:with-param name="block">
                  <xsl:apply-templates mode="render-content" select="/root/gmd:MD_Metadata//gmd:identificationInfo/*/gmd:resourceConstraints/*[name()=('gmd:MD_LegalConstraints')]"/>
                </xsl:with-param>
              </xsl:call-template>
            </div>
          </div>
        </div>
      </article>
    </div>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:identificationInfo/*/gmd:resourceConstraints/*[name()=('gmd:MD_LegalConstraints') and count(gmd:otherConstraints) > 0]">
    <xsl:call-template name="render-block-as-row-with-header">
      <xsl:with-param name="header">
        <xsl:if test="count(gmd:accessConstraints/gmd:MD_RestrictionCode[@codeListValue='otherRestrictions']) > 0"><xsl:value-of select="gn-fn-iso19139:get-schema-strings($schemaStrings, 'mdAccessConstraints')"/></xsl:if>
        <xsl:if test="count(gmd:useConstraints/gmd:MD_RestrictionCode[@codeListValue='otherRestrictions']) > 0"><xsl:value-of select="gn-fn-iso19139:get-schema-strings($schemaStrings, 'mdUseConstraints')"/></xsl:if>
      </xsl:with-param>
      <xsl:with-param name="block">
        <xsl:if test="count(gmd:otherConstraints) > 0">
          <xsl:apply-templates mode="render-content" select="gmd:otherConstraints"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:otherConstraints[gco:CharacterString]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="gn-fn-iso19139:get-schema-strings($schemaStrings, 'mdOtherConstraints')"/>
      <xsl:with-param name="value" select="gco:CharacterString/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:otherConstraints[gmx:Anchor]" priority="100">
    <xsl:variable name="label" select="gn-fn-iso19139:get-schema-strings($schemaStrings, 'mdOtherConstraints')"/>
    <xsl:variable name="link" select="normalize-space(gmx:Anchor/@xlink:href)"/>
    <xsl:variable name="value" select="normalize-space(gmx:Anchor/text())"/>
    <xsl:if test="not($link)">
      <xsl:call-template name="render-text-as-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="value" select="$value"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$link!=''">
      <xsl:call-template name="render-anchor-as-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="link" select="$link"/>
        <xsl:with-param name="value" select="if ($value!='') then $value else $link"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="getMetadataHeader" match="gmd:MD_Metadata">
    <div class="gn-abstract">
      <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:for-each>
    </div>
  </xsl:template>
</xsl:stylesheet>
