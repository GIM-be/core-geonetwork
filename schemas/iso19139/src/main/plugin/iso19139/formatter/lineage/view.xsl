<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
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
              <xsl:apply-templates mode="render-content" select="/root/gmd:MD_Metadata//gmd:lineage"/>
            </div>
          </div>
        </div>
      </article>
    </div>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:lineage">
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:LI_Lineage/gmd:statement"/>
        <xsl:for-each select="gmd:LI_Lineage/gmd:processStep">
          <xsl:variable name="processStep" select="."/>
          <xsl:call-template name="render-block-as-row-with-header">
            <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
            <xsl:with-param name="block">
              <xsl:apply-templates mode="render-content" select="$processStep/gmd:LI_ProcessStep/gmd:description"/>
              <xsl:apply-templates mode="render-content" select="$processStep/gmd:LI_ProcessStep/gmd:dateTime"/>
              <xsl:call-template name="render-block-as-row-with-header">
                <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:processor', 'gmd:LI_ProcessStep')"/>
                <xsl:with-param name="block">
                  <xsl:apply-templates mode="render-content"
                                       select="$processStep/gmd:LI_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:CI_ResponsibleParty">
    <xsl:apply-templates mode="render-content" select="gmd:individualName"/>
    <xsl:apply-templates mode="render-content" select="gmd:organisationName"/>
    <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact">
      <xsl:apply-templates mode="render-content" select="gmd:phone/gmd:CI_Telephone/gmd:voice"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:deliveryPoint"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:city"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:postalCode"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:country"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:electronicMailAddress"/>
      <xsl:apply-templates mode="render-content" select="gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage"/>
    </xsl:for-each>
    <xsl:apply-templates mode="render-content" select="gmd:role/gmd:CI_RoleCode"/>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:electronicMailAddress[gco:CharacterString|gmx:Anchor]">
    <xsl:call-template name="render-url-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="url" select="gco:CharacterString|gmx:Anchor"/>
      <xsl:with-param name="prefix" select="'mailto:'"/>
    </xsl:call-template>
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
