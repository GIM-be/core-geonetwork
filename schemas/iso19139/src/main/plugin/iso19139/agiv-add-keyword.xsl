<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink">

  <!-- match descriptiveKeywords elements -->
  <xsl:template
    match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords | gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:descriptiveKeywords">
    <xsl:call-template name="addKeyword"/>
  </xsl:template>

  <!-- in case gmd:MD_DataIdentification does not have a gmd:descriptiveKeywords using  'GDI-Vlaanderen Trefwoorden', insert it at correct position -->
  <xsl:template
    match="gmd:identificationInfo/*[(name()='gmd:MD_DataIdentification' or name()='srv:SV_ServiceIdentification') and
    count(gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title[normalize-space(gco:CharacterString) = $thesaurusTitleString or normalize-space(gmx:Anchor) = $thesaurusTitleString]) = 0]">
    <!-- all elements allowed to follow descriptiveKeywords in MD_DataIdentification or SV_ServiceIdentification -->
    <xsl:call-template name="addThesaurusAndKeyword"/>
  </xsl:template>

  <!-- match descriptiveKeywords elements -->
  <xsl:template name="addKeyword">
    <xsl:choose>
      <!-- this descriptiveKeywords uses 'GDI-Vlaanderen Trefwoorden'  -->
      <xsl:when
        test="gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString = $thesaurusTitleString or gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/gmx:Anchor = $thesaurusTitleString">
        <gmd:descriptiveKeywords>
          <gmd:MD_Keywords>
            <!-- put out each keyword -->
            <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
              <xsl:copy-of copy-namespaces="no" select="."/>
            </xsl:for-each>
            <!-- if the INSPIRE keyword marker isn't already here, put it out -->
            <xsl:if
              test="count(gmd:MD_Keywords/gmd:keyword[gco:CharacterString = $keywordString and gmx:Anchor = $keywordString]) = 0">
              <gmd:keyword>
                <gmx:Anchor xlink:href="{$keywordAnchor}">
                  <xsl:value-of select="$keywordString"/>
                </gmx:Anchor>
              </gmd:keyword>
            </xsl:if>
            <!-- do not forget to put out sibling element thesaurusName -->
            <xsl:for-each select="gmd:MD_Keywords/gmd:thesaurusName">
              <xsl:copy-of copy-namespaces="no" select="."/>
            </xsl:for-each>
          </gmd:MD_Keywords>
        </gmd:descriptiveKeywords>
      </xsl:when>
      <!-- this descriptiveKeywords does not use the keyword to be added: just put out  -->
      <xsl:otherwise>
        <xsl:copy-of copy-namespaces="no" select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- in case gmd:MD_DataIdentification does not have a gmd:descriptiveKeywords using  'GDI-Vlaanderen Trefwoorden', insert it at correct position -->
  <xsl:template
    name="addThesaurusAndKeyword">
    <!-- all elements allowed to follow descriptiveKeywords in MD_DataIdentification -->
    <xsl:variable name="elements-after"
                  select="gmd:resourceSpecificUsage|gmd:resourceConstraints|gmd:aggregationInfo|gmd:spatialRepresentationType|gmd:spatialResolution|gmd:language|gmd:characterSet|gmd:topicCategory|gmd:environmentDescription|gmd:extent|gmd:supplementalInformation|srv:*"/>
    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="* except $elements-after" copy-namespaces="no" />
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <gmd:keyword>
            <gmx:Anchor xlink:href="{$keywordAnchor}">
              <xsl:value-of select="$keywordString"/>
            </gmx:Anchor>
          </gmd:keyword>
          <gmd:type>
            <gmd:MD_KeywordTypeCode
              codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_KeywordTypeCode"
              codeListValue="theme"/>
          </gmd:type>
          <gmd:thesaurusName>
            <gmd:CI_Citation>
              <gmd:title>
                <gmx:Anchor xlink:href="{$thesaurusTitleAnchor}">
                  <xsl:value-of select="$thesaurusTitleString"/>
                </gmx:Anchor>
              </gmd:title>
              <gmd:date>
                <gmd:CI_Date>
                  <gmd:date>
                    <gco:Date>
                      <xsl:value-of select="$thesaurusDate"/>
                    </gco:Date>
                  </gmd:date>
                  <gmd:dateType>
                    <gmd:CI_DateTypeCode
                      codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode"
                      codeListValue="publication"/>
                  </gmd:dateType>
                </gmd:CI_Date>
              </gmd:date>
            </gmd:CI_Citation>
          </gmd:thesaurusName>
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>
      <xsl:copy-of select="$elements-after" copy-namespaces="no" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
