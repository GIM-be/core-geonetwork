<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gfc="http://www.isotc211.org/2005/gfc"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">
  <xsl:include href="variables.xsl"/>
  <xsl:include href="starting-point.xsl"/>
  <xsl:include href="sharedFormatterDir/xslt/render-functions.xsl"/>

  <!-- =============================================  -->
  <!-- Content templates                              -->
  <!-- Responsible for the order of the elements      -->
  <!-- =============================================  -->
  <xsl:template mode="render-content" match="gfc:FC_FeatureCatalogue">
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gfc:FC_FeatureCatalogue', name())"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmx:name|gfc:name"/>
        <xsl:apply-templates mode="render-content" select="gmx:scope|gfc:scope"/>
        <xsl:apply-templates mode="render-content" select="gmx:fieldOfApplication|gfc:fieldOfApplication"/>
        <xsl:apply-templates mode="render-content" select="gmx:versionNumber|gfc:versionNumber"/>
        <xsl:apply-templates mode="render-content" select="gmx:versionDate|gfc:versionDate"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gfc:producer', name())"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gfc:producer"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-block">
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gfc:functionalLanguage"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gfc:featureType', name())"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gfc:featureType"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="'Metadata informatie'"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="@uuid"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gfc:producer">
    <xsl:for-each select="gmd:CI_ResponsibleParty">
      <xsl:call-template name="render-block">
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="."/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
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

  <xsl:template mode="render-content" match="gfc:featureType">
    <xsl:for-each select="gfc:FC_FeatureType">
      <xsl:call-template name="render-block">
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="gfc:typeName"/>
          <xsl:apply-templates mode="render-content" select="gfc:definition"/>
          <xsl:apply-templates mode="render-content" select="gfc:code"/>
          <xsl:apply-templates mode="render-content" select="gfc:isAbstract"/>
          <xsl:apply-templates mode="render-content" select="gfc:aliases"/>
          <xsl:call-template name="render-block-as-row-with-header">
            <xsl:with-param name="header" select="'Attributentabel'"/>
            <xsl:with-param name="block">
              <table>
                <tbody>
                  <tr>
                    <th><xsl:value-of select="tr:nodeLabel($schemaLoc,'gfc:memberName','gfc:FC_FeatureAttribute')"/></th>
                    <th><xsl:value-of select="tr:nodeLabel($schemaLoc,'gfc:definition','gfc:FC_FeatureAttribute')"/></th>
                    <th><xsl:value-of select="tr:nodeLabel($schemaLoc,'gfc:code','gfc:FC_FeatureAttribute')"/></th>
                    <th><xsl:value-of select="tr:nodeLabel($schemaLoc,'gfc:cardinality','gfc:FC_FeatureAttribute')"/></th>
                    <th><xsl:value-of select="tr:nodeLabel($schemaLoc,'gfc:valueType','gfc:FC_FeatureAttribute')"/></th>
                  </tr>
                  <xsl:apply-templates mode="render-content" select="gfc:carrierOfCharacteristics"/>
                </tbody>
              </table>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="render-content" match="gfc:carrierOfCharacteristics">
      <xsl:for-each select="gfc:FC_FeatureAttribute">
        <tr>
          <td>
            <strong><xsl:value-of select="gfc:memberName/gco:LocalName"/></strong>
          </td>
          <td><xsl:value-of select="gfc:definition/gco:CharacterString"/></td>
          <td>
            <strong><xsl:value-of select="gfc:code/gco:CharacterString"/></strong>
          </td>
          <td>
            <xsl:variable name="multiplicityRange" select="gfc:cardinality/gco:Multiplicity/gco:range/gco:MultiplicityRange"/>
            <xsl:variable name="minValue" select="$multiplicityRange/gco:lower/gco:Integer"/>
            <xsl:variable name="maxValue" select="$multiplicityRange/gco:upper/gco:UnlimitedInteger"/>
            <xsl:variable name="isInfinite" select="$multiplicityRange/gco:upper/gco:UnlimitedInteger/@isInfinite"/>
            <xsl:variable name="value">
              <xsl:choose>
                <xsl:when test="$isInfinite">n</xsl:when>
                <xsl:otherwise><xsl:value-of select="$maxValue"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            [<xsl:value-of  select="$minValue"/>, <xsl:value-of select="$value"/>]
          </td>
          <td><xsl:value-of select="gfc:valueType/gco:TypeName/gco:aName/gco:CharacterString/text()"/></td>
        </tr>
        <xsl:variable name="fcListedValue" select="gfc:listedValue/gfc:FC_ListedValue" />
        <xsl:if test="count($fcListedValue/gfc:code[gco:CharacterString!=''])>0 or count($fcListedValue/gfc:label[gco:CharacterString!=''])>0 or count($fcListedValue/gfc:definition[gco:CharacterString!=''])>0">
          <tr>
            <td colspan="5">
              <div>
                <h5>Lijst met waarden</h5>
                <table>
                  <tbody>
                    <tr>
                      <th><label><xsl:value-of select="tr:nodeLabel($schemaLoc,'gfc:code','gfc:FC_ListedValue')"/></label></th>
                      <th><label><xsl:value-of select="tr:nodeLabel($schemaLoc,'gfc:label','gfc:FC_ListedValue')"/></label></th>
                      <th><label><xsl:value-of select="tr:nodeLabel($schemaLoc,'gfc:definition','gfc:FC_ListedValue')"/></label></th>
                    </tr>
                    <xsl:for-each select="$fcListedValue">
                      <tr>
                        <td><xsl:value-of select="normalize-space(gfc:code/gco:CharacterString/text())"/></td>
                        <td><xsl:value-of select="normalize-space(gfc:label/gco:CharacterString/text())"/></td>
                        <td><xsl:value-of select="normalize-space(gfc:definition/gco:CharacterString/text())"/></td>
                      </tr>
                    </xsl:for-each>
                  </tbody>
                </table>
              </div>
            </td>
          </tr>
        </xsl:if>
      </xsl:for-each>
  </xsl:template>

  <!--xsl:template mode="render-content" match="gfc:cardinality">
    <xsl:variable name="minValue" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:lower/gco:Integer"/>
    <xsl:variable name="maxValue" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:upper/gco:UnlimitedInteger"/>
    <xsl:variable name="isInfinite" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:upper/gco:UnlimitedInteger/@isInfinite"/>
    <xsl:call-template name="render-block-as-row-with-header">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:lower"/>
        <xsl:apply-templates mode="render-content" select="gco:Multiplicity/gco:range/gco:MultiplicityRange/gco:upper"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template-->

  <xsl:template mode="render-content" match="*[gco:CharacterString]">
    <xsl:variable name="context">
      <xsl:choose>
        <xsl:when test="name()='gmd:title'">
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

  <xsl:template mode="render-content" match="@uuid" priority="1000">
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="'Identifier'"/>
      <xsl:with-param name="content" select="normalize-space(.)"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gco:Record|gco:LocalName|gco:Measure|gco:Length|gco:Angle|gmx:FileName|
  gco:Scale|gco:RecordType|gmx:MimeFileType|gml:beginPosition|gml:endPosition" priority="1000">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Integer]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="gco:Integer/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:UnlimitedInteger]">
    <xsl:variable name="value">
      <xsl:choose>
        <xsl:when test="gco:UnlimitedInteger/@isInfinite">n</xsl:when>
        <xsl:otherwise><xsl:value-of select="gco:UnlimitedInteger/text()"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="$value"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Decimal|gco:Real]">
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
            <xsl:when test="$output='pdf'">
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
            <xsl:when test="$output='pdf'">
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
</xsl:stylesheet>
