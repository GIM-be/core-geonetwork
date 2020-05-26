<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:xslUtils="java:org.fao.geonet.util.XslUtil"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <xsl:include href="./min-utility-fn.xsl"/>
  <xsl:include href="./variables.xsl"/>
  <xsl:include href="./starting-point.xsl"/>


  <xsl:template mode="render-content" match="*|@*">
    <!-- Ignore everything else -->
    <xsl:message select="concat('Ignoring ', name(..), '/', name(.))"/>
  </xsl:template>

  <!-- =============================================  -->
  <!-- Content templates                              -->
  <!-- Responsible the order of the elements          -->
  <!-- =============================================  -->
  <xsl:template mode="render-content" match="gmd:MD_Metadata">
    <!-- Display content of every tabs -->
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-identificationInfo'"/>
      <xsl:with-param name="content" select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation"/>
    </xsl:call-template>
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-contentInfo'"/>
      <xsl:with-param name="content" select="gmd:identificationInfo/gmd:MD_DataIdentification"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Render Sections -->
  <xsl:template mode="render-content" match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation">
    <xsl:call-template name="render-block">
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:title"/>
        <xsl:apply-templates mode="render-content" select="gmd:alternateTitle"/>
        <xsl:for-each select="gmd:date">
          <xsl:apply-templates mode="render-content" select="gmd:CI_Date/gmd:date"/>
          <xsl:apply-templates mode="render-content" select="gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode"/>
        </xsl:for-each>
        <xsl:apply-templates mode="render-content" select="gmd:edition"/>
        <xsl:apply-templates mode="render-content" select="gmd:identifier/gmd:MD_Identifier/gmd:code"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:identificationInfo/gmd:MD_DataIdentification">
    <xsl:call-template name="render-block">
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:abstract"/>
        <xsl:apply-templates mode="render-content" select="gmd:purpose"/>
        <xsl:apply-templates mode="render-content" select="gmd:status/gmd:MD_ProgressCode"/>
        <xsl:apply-templates mode="render-content" select="gmd:pointOfContact/gmd:CI_ResponsibleParty"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:pointOfContact/gmd:CI_ResponsibleParty">
    <xsl:call-template name="render-block-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(..), name(../..))"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:individualName"/>
        <xsl:apply-templates mode="render-content" select="gmd:organisationName"/>
        <xsl:apply-templates mode="render-content" select="gmd:role/gmd:CI_RoleCode"/>
        <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact">
          <xsl:apply-templates mode="render-content" select="gmd:phone/gmd:CI_Telephone/gmd:voice"/>
          <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:deliveryPoint"/>
          <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:city"/>
          <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:postalCode"/>
          <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:country"/>
          <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:electronicMailAddress"/>
          <xsl:apply-templates mode="render-content" select="gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage"/>
        </xsl:for-each>
        <xsl:apply-templates mode="render-content" select="gmd:descriptiveKeywords"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <!-- Generic templates -->
  <xsl:template mode="render-content" match="*[gco:CharacterString]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="gco:CharacterString/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gmx:Anchor]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="gmx:Anchor/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Date]">
    <xsl:call-template name="render-date-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="date" select="gco:Date/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[@codeListValue]">
    <xsl:call-template name="render-codelist-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(..), name(../..))"/>
      <xsl:with-param name="codelist" select="@codeListValue"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gmd:URL]">
    <xsl:call-template name="render-url-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="url" select="gmd:URL"/>
    </xsl:call-template>
  </xsl:template>


  <!-- More specific Templates -->
  <xsl:template mode="render-content" match="gmd:electronicMailAddress[gco:CharacterString|gmx:Anchor]">
    <xsl:call-template name="render-url-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="url" select="gco:CharacterString|gmx:Anchor"/>
      <xsl:with-param name="prefix" select="'mailto:'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- =============================================  -->
  <!-- Formatter templates                            -->
  <!-- Utility templates to format content before     -->
  <!-- displaying it                                  -->
  <!-- =============================================  -->
  <xsl:template name="render-text-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="value" as="xs:string"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content" select="$value"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="render-date-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="date" as="xs:string"/>
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
  </xsl:template>

  <xsl:template name="render-codelist-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="codelist" as="node()"/>
    <xsl:variable name="codelistLabel" select="tr:codelist-value-label($schemaLoc, local-name($codelist/..), $codelist)"/>
    <xsl:variable name="codelistDesc" select="tr:codelist-value-desc($schemaLoc, local-name($codelist/..), $codelist)"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content">
        <strong>
          <xsl:value-of select="concat($codelistLabel, ': ')"/>
        </strong>
        <xsl:value-of select="$codelistDesc"/>
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

  <xsl:template name="render-url-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="prefix" as="xs:string" select="''"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content">
        <a href="{concat($prefix, $url)}" target="_blank">
          <xsl:value-of select="$url"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <!-- =============================================  -->
  <!-- Renderer templates                             -->
  <!-- Responsible for the layout                     -->
  <!-- =============================================  -->
  <xsl:template name="render-tab">
    <xsl:param name="tabId" as="xs:string"/>
    <xsl:param name="content" as="node()"/>
    <xsl:variable name="renderedContent">
      <xsl:apply-templates  mode="render-content" select="$content"/>
    </xsl:variable>
    <xsl:if test="normalize-space($renderedContent)">
      <div class="tab-pane">
        <xsl:attribute name="id" select="$tabId"/>
        <xsl:copy-of select="$renderedContent"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-block">
    <xsl:param name="block" as="node()"/>
    <table class="table table-striped">
      <tbody>
        <xsl:copy-of select="$block"/>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="render-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="content"/>
    <tr>
      <th>
        <xsl:value-of select="$label"/>
      </th>
      <td>
        <xsl:copy-of select="$content"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
