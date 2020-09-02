<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gfc="http://www.isotc211.org/2005/gfc"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gn-fn-index="http://geonetwork-opensource.org/xsl/functions/index"
                version="2.0">

  <xsl:import href="common/index-utils.xsl"/>

  <xsl:template match="/">
    <xsl:variable name="jsonFeatureTypes">[
      <xsl:for-each select="/gfc:FC_FeatureCatalogue/gfc:featureType">{
        "typeName" : "<xsl:value-of select="gn-fn-index:json-escape(gfc:FC_FeatureType/gfc:typeName/*/text())"/>",
        "definition" :"<xsl:value-of select="gn-fn-index:json-escape(gfc:FC_FeatureType/gfc:definition/*/text())"/>",
        "code" :"<xsl:value-of select="gfc:FC_FeatureType/gfc:code/*/text()"/>",
        "isAbstract" :"<xsl:value-of select="gfc:FC_FeatureType/gfc:isAbstract/*/text()"/>",
        "aliases" : "<xsl:value-of select="gfc:FC_FeatureType/gfc:aliases/*/text()"/>",
        <!--"inheritsFrom" : "<xsl:value-of select="gfc:FC_FeatureType/gfc:inheritsFrom/*/text()"/>",
        "inheritsTo" : "<xsl:value-of select="gfc:FC_FeatureType/gfc:inheritsTo/*/text()"/>",
        "constrainedBy" : "<xsl:value-of select="gfc:FC_FeatureType/gfc:constrainedBy/*/text()"/>",
        "definitionReference" : "<xsl:value-of select="gfc:FC_FeatureType/gfc:definitionReference/*/text()"/>",-->
        <!-- Index attribute table as JSON object -->
        <xsl:variable name="attributes"
                      select="*/gfc:carrierOfCharacteristics"/>
        <xsl:if test="count($attributes) > 0">
          "attributeTable" : [
          <xsl:for-each select="$attributes">
            <xsl:variable name="cardinality" select="*/gfc:cardinality/gco:Multiplicity/gco:range/gco:MultiplicityRange"/>
            {"name": "<xsl:value-of select="*/gfc:memberName/*/text()"/>",
            "definition": "<xsl:value-of select="gn-fn-index:json-escape(*/gfc:definition/*/text())"/>",
            "code": "<xsl:value-of select="*/gfc:code/*/text()"/>",
            "link": "<xsl:value-of select="*/gfc:code/*/@xlink:href"/>",
            "type": "<xsl:value-of select="*/gfc:valueType/gco:TypeName/gco:aName/*/text()"/>",
            "min": "<xsl:value-of select="$cardinality/gco:lower/*/text()"/>",
            "max": "<xsl:value-of select="if ($cardinality/gco:upper/*/@isInfinite = 'true') then 'infinite' else $cardinality/gco:upper/*/text()"/>"
            <xsl:if test="*/gfc:listedValue">
              ,"values": [
              <xsl:for-each select="*/gfc:listedValue">{
                "label": "<xsl:value-of select="*/gfc:label/*/text()"/>",
                "code": "<xsl:value-of select="*/gfc:code/*/text()"/>",
                "definition": "<xsl:value-of select="*/gfc:definition/*/text()"/>"}
                <xsl:if test="position() != last()">,</xsl:if>
              </xsl:for-each>
              ]
            </xsl:if>
            }
            <xsl:if test="position() != last()">,</xsl:if>
          </xsl:for-each>
          ]
        </xsl:if>
        }
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:for-each>
      ]
    </xsl:variable>
    <featureTypes>
      <xsl:value-of select="$jsonFeatureTypes"/>
    </featureTypes>
  </xsl:template>
</xsl:stylesheet>
