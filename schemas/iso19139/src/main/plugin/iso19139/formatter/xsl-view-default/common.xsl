<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:xslUtils="java:org.fao.geonet.util.XslUtil"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <!-- =============================================  -->
  <!-- Common templates                              -->
  <!-- =============================================  -->
  <xsl:template mode="render-content" match="*[gco:CharacterString]">
    <xsl:variable name="context">
      <xsl:choose>
        <xsl:when test="name()=('gmd:title','gmd:edition')">
          <xsl:value-of select="name(../..)"/></xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name(..)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), $context)"/>
      <xsl:with-param name="value" select="gco:CharacterString/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Integer]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="gco:Integer/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Decimal]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="gco:Decimal/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Distance]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="concat(gco:Distance/text(),' ',gco:Distance/@uom)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Boolean]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="gco:Boolean = 'true'">
            <xsl:value-of select="$schemaStrings/trueValue"/>
          </xsl:when>
          <xsl:when test="gco:Boolean = 'false'">
            <xsl:value-of select="$schemaStrings/falseValue"/>
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gmx:Anchor]">
    <xsl:variable name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
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

  <xsl:template mode="render-content" match="*[gco:Date|gco:DateTime]">
    <xsl:call-template name="render-date-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="date" select="gco:Date/text()|gco:DateTime/text()"/>
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

  <xsl:template mode="render-content" match="*[gmd:URL]">
    <xsl:call-template name="render-url-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="url" select="gmd:URL"/>
    </xsl:call-template>
  </xsl:template>

  <!-- =============================================  -->
  <!-- Formatter templates                            -->
  <!-- Utility templates to format content before     -->
  <!-- displaying it                                  -->
  <!-- =============================================  -->
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

  <xsl:template name="render-codelist-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="codelist" as="node()"/>
    <xsl:variable name="codelistLabel" select="tr:codelist-value-label($schemaLoc, local-name($codelist/..), $codelist)"/>
    <xsl:variable name="codelistDesc" select="tr:codelist-value-desc($schemaLoc, local-name($codelist/..), $codelist)"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content">
        <xsl:if test="$codelistDesc">
          <xsl:choose>
            <xsl:when test="$output = ('pdf', 'html')">
              <xsl:value-of select="concat($codelistLabel, ': ')"/>
            </xsl:when>
            <xsl:otherwise>
              <strong>
                <xsl:value-of select="concat($codelistLabel, ': ')"/>
              </strong>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="$codelistDesc"/>
        </xsl:if>
        <xsl:if test="not($codelistDesc)">
          <xsl:value-of select="$codelistLabel"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="render-block-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="block" as="node()"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content">
        <xsl:call-template name="render-block">
          <xsl:with-param name="block" select="$block"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
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

  <xsl:template name="render-url-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="prefix" as="xs:string" select="''"/>
    <xsl:if test="$url!=''">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content">
          <xsl:choose>
            <xsl:when test="$output = 'pdf'">
              <xsl:value-of select="$url"/>
            </xsl:when>
            <xsl:otherwise>
              <a class="gn-break" href="{concat($prefix, $url)}" target="_blank">
                <xsl:value-of select="$url"/>
              </a>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-anchor-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="link" as="xs:string"/>
    <xsl:param name="value" as="xs:string"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content">
        <xsl:choose>
          <xsl:when test="$output = ('pdf', 'html')">
            <xsl:value-of select="$value"/>
          </xsl:when>
          <xsl:otherwise>
            <a href="{$link}" target="_blank">
              <xsl:value-of select="$value"/>
            </a>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="render-button-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="button"/>
    <xsl:if test="normalize-space($button)">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content" select="$button"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- =============================================  -->
  <!-- Renderer templates                             -->
  <!-- Responsible for the layout                     -->
  <!-- =============================================  -->
  <xsl:template name="render-tab">
    <xsl:param name="tabId" as="xs:string"/>
    <xsl:param name="content"/>
    <xsl:if test="normalize-space($content)">
      <xsl:if test="$output = ('pdf', 'html')">
        <h2><xsl:value-of select="gn-fn-iso19139:get-schema-strings($schemaStrings, substring-after($tabId,'gn-tab-'))"/></h2>
      </xsl:if>
      <div class="tab-pane">
        <xsl:attribute name="id" select="$tabId"/>
        <xsl:copy-of select="$content"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-block">
    <xsl:param name="header" required="no"/>
    <xsl:param name="block" as="node()"/>
    <xsl:if test="normalize-space($block)">
      <xsl:if test="$header">
        <h3 class="view-header gp-header"><xsl:value-of select="$header"/></h3>
      </xsl:if>
      <table class="table table-striped">
        <tbody>
          <xsl:copy-of select="$block"/>
        </tbody>
      </table>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="content"/>
    <tr>
      <th>
        <xsl:if test="name(.)='gmd:denominator'"><xsl:attribute name="style">white-space: nowrap;</xsl:attribute></xsl:if>
        <xsl:value-of select="$label"/>
      </th>
      <td>
        <xsl:copy-of select="$content"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="render-row-with-colspan">
    <xsl:param name="header" as="xs:string"/>
    <xsl:param name="content"/>
    <tr>
      <td colspan="2" class="gp-nest-row">
        <h3 class="view-header gp-header"><xsl:value-of select="$header"/></h3>
        <xsl:copy-of select="$content"/>
      </td>
    </tr>
  </xsl:template>

  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="gmd:MD_Metadata">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="gmd:MD_Metadata">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="getMetadataHierarchyLevel" match="gmd:MD_Metadata">
    <xsl:value-of select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
  </xsl:template>


</xsl:stylesheet>
