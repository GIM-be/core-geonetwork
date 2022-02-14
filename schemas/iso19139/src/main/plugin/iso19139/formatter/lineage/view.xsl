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

  <xsl:include href="../xsl-view-default/min-utility-fn.xsl"/>
  <xsl:include href="../xsl-view-default/variables.xsl"/>
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


  <xsl:template name="render-tab">
    <xsl:param name="tabId" as="xs:string"/>
    <xsl:param name="content"/>
    <xsl:if test="normalize-space($content)">
      <div class="tab-pane">
        <xsl:attribute name="id" select="$tabId"/>
        <xsl:copy-of select="$content"/>
      </div>
    </xsl:if>
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


  <xsl:template mode="render-content" match="*[gco:CharacterString]">
    <xsl:variable name="context">
      <xsl:choose>
        <xsl:when test="name()='gmd:title'">
          <xsl:value-of select="name(../..)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name(..)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), $context)"/>
      <xsl:with-param name="value" select="gco:CharacterString/text()"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template mode="render-content" match="*[gmd:URL]">
    <xsl:call-template name="render-url-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="url" select="gmd:URL"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template mode="render-content" match="*[gco:Date|gco:DateTime]">
    <xsl:call-template name="render-date-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="date" select="gco:Date/text()|gco:DateTime/text()"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template mode="render-content" match="gmd:electronicMailAddress[gco:CharacterString|gmx:Anchor]">
    <xsl:call-template name="render-url-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="url" select="gco:CharacterString|gmx:Anchor"/>
      <xsl:with-param name="prefix" select="'mailto:'"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template mode="render-content" match="*[@codeListValue]">
    <xsl:if test="normalize-space(@codeListValue)">
      <xsl:variable name="context">
        <xsl:choose>
          <xsl:when test="name(../..)='gmd:MD_Metadata'">
            <xsl:value-of select="concat('/',name(../..),'/',name(..))"/></xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="name(../..)"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="render-codelist-as-row">
        <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(..), $context)"/>
        <xsl:with-param name="codelist" select="@codeListValue"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="render-block">
    <xsl:param name="header" required="no"/>
    <xsl:param name="block" as="node()"/>
    <xsl:if test="normalize-space($block)">
      <xsl:if test="$header">
        <h3 class="view-header gp-header">
          <xsl:value-of select="$header"/>
        </h3>
      </xsl:if>
      <table class="table table-striped">
        <tbody>
          <xsl:copy-of select="$block"/>
        </tbody>
      </table>
    </xsl:if>
  </xsl:template>


  <xsl:template name="render-url-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="prefix" as="xs:string" select="''"/>
    <xsl:if test="$url!=''">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content">
          <a class="gn-break" href="{concat($prefix, $url)}" target="_blank">
            <xsl:value-of select="$url"/>
          </a>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="render-date-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="date" />
    <xsl:if test="normalize-space($date)">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content">
          <span data-gn-humanize-time="{.}">
            <xsl:attribute name="data-format">
              <xsl:choose>
                <xsl:when test="matches($date, '[0-9]{4}-[0-9]{2}-[0-9]{2}')">DD/MM/YYYY</xsl:when>
                <xsl:when test="matches($date, '[0-9]{4}-[0-9]{2}')">MMM YYYY</xsl:when>
                <xsl:when test="matches($date, '[0-9]{4}')">YYYY</xsl:when>
                <xsl:otherwise/>
              </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
          </span>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="render-block-as-row-with-header">
    <xsl:param name="header" as="xs:string"/>
    <xsl:param name="block" as="node()"/>
    <xsl:if test="normalize-space($block)">
      <xsl:call-template name="render-row-with-colspan">
        <xsl:with-param name="header" select="$header"/>
        <xsl:with-param name="content">
          <xsl:call-template name="render-block">
            <xsl:with-param name="block" select="$block"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="render-row-with-colspan">
    <xsl:param name="header" as="xs:string"/>
    <xsl:param name="content"/>
    <tr>
      <td colspan="2" class="gp-nest-row">
        <h3 class="view-header gp-header">
          <xsl:value-of select="$header"/>
        </h3>
        <xsl:copy-of select="$content"/>
      </td>
    </tr>
  </xsl:template>


  <xsl:template name="render-text-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="value"/>
    <xsl:if test="normalize-space($value)">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content" select="$value"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="render-codelist-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="codelist" as="node()"/>
    <xsl:variable name="codelistLabel" select="tr:codelist-value-label($schemaLoc, local-name($codelist/..), $codelist)"/>
    <xsl:variable name="codelistDesc" select="tr:codelist-value-desc($schemaLoc, local-name($codelist/..), $codelist)"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content">
        <xsl:if test="$codelistDesc">
          <strong>
            <xsl:value-of select="concat($codelistLabel, ': ')"/>
          </strong>
          <xsl:value-of select="$codelistDesc"/>
        </xsl:if>
        <xsl:if test="not($codelistDesc)">
          <xsl:value-of select="$codelistLabel"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="render-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="content"/>
    <tr>
      <th>
        <xsl:if test="name(.)='gmd:denominator'">
          <xsl:attribute name="style">white-space: nowrap;</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="$label"/>
      </th>
      <td>
        <xsl:copy-of select="$content"/>
      </td>
    </tr>
  </xsl:template>


  <!-- UTILS -->
  <xsl:template mode="getMetadataTitle" match="gmd:MD_Metadata">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


  <xsl:template mode="getMetadataHierarchyLevel" match="gmd:MD_Metadata">
    <xsl:value-of select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
  </xsl:template>


  <xsl:template mode="getMetadataHeader" match="gmd:MD_Metadata">
    <div class="gn-abstract">
      <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:for-each>
    </div>
    <div class="one-line-ellipsis" ng-if="user.isEditorOrMore()">
      <p>
        <span data-translate="">owner</span>: {{md.getOwnername()}}
      </p>
    </div>
    <div data-ng-if="user.isEditorOrMore() &amp;&amp; md.mdStatus&lt;50 &amp;&amp; isMdWorkflowEnable">
      <i class="fa gn-aiv-workflow-status-all gn-aiv-workflow-status-{{{{(md.mdStatus==2 || md.mdStatus==3) ? 'unlocked' : 'locked'}}}} gn-aiv-workflow-status-{{{{(md.mdStatus &amp;&amp; md.mdStatus &lt; 7) ? md.mdStatus : 'x'}}}}">
        <span>{{'mdStatusRecord' | translate}}: {{('mdStatus-' + md.mdStatus) | translate}}</span>
      </i>
    </div>
  </xsl:template>
</xsl:stylesheet>