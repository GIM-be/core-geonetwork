<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">


  <xsl:function name="gn-fn-iso19139:getLangId" as="xs:string">
    <xsl:param name="md"/>
    <xsl:param name="lang"/>
    <xsl:choose>
      <xsl:when
        test="$md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang]/@id">
        <xsl:value-of
          select="concat('#', $md/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue = $lang]/@id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('#', upper-case($lang))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:function name="gn-fn-iso19139:get-schema-strings" as="xs:string">
    <xsl:param name="strings" as="node()"/>
    <xsl:param name="key" as="xs:string"/>

    <xsl:variable name="nameInStrings"
                  select="$strings/*[name() = $key]"/>
    <xsl:value-of select="if ($nameInStrings != '')
                          then $nameInStrings
                          else $key"/>
  </xsl:function>


  <xsl:template name="localised" mode="localised" match="*[gco:CharacterString or gmd:PT_FreeText]">
    <xsl:param name="langId"/>
    <xsl:choose>
      <xsl:when
        test="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId] and
        gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId] != ''">
        <xsl:value-of
          select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId]"/>
      </xsl:when>
      <xsl:when test="not(gco:CharacterString)">
        <!-- If no CharacterString, try to use the first textGroup available -->
        <xsl:value-of
          select="gmd:PT_FreeText/gmd:textGroup[position()=1]/gmd:LocalisedCharacterString"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="gco:CharacterString"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
