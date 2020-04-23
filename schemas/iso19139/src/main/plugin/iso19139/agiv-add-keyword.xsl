<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink">

  <!-- Match "GDI-Vlaanderen Trefwoorden" descriptiveKeywords block -->
  <xsl:template match="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[name() = ('gco:CharacterString', 'gmx:Anchor')] = $thesaurusTitleString]">
    <xsl:choose>
      <xsl:when test="count(gmd:MD_Keywords/gmd:keyword[gco:CharacterString = $keywordString and gmx:Anchor = $keywordAnchor]) = 0">
        <xsl:call-template name="addKeyword"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of copy-namespaces="no" select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- In case gmd:MD_DataIdentification does not have a gmd:descriptiveKeywords using  'GDI-Vlaanderen Trefwoorden', insert it at correct position -->
  <xsl:template match="gmd:identificationInfo/*[name() = ('gmd:MD_DataIdentification', 'srv:SV_ServiceIdentification') and
                       count(gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title[normalize-space(gco:CharacterString) = $thesaurusTitleString or normalize-space(gmx:Anchor) = $thesaurusTitleString]) = 0]">
    <!-- all elements allowed to follow descriptiveKeywords in MD_DataIdentification or SV_ServiceIdentification -->
    <xsl:variable name="elements-after"
                  select="gmd:resourceSpecificUsage|
                          gmd:resourceConstraints|
                          gmd:aggregationInfo|
                          gmd:spatialRepresentationType|
                          gmd:spatialResolution|
                          gmd:language|
                          gmd:characterSet|
                          gmd:topicCategory|
                          gmd:environmentDescription|
                          gmd:extent|
                          gmd:supplementalInformation|
                          srv:*"/>

    <xsl:copy copy-namespaces="no">
      <xsl:copy-of select="* except $elements-after" copy-namespaces="no" />
      <xsl:call-template name="addThesaurusAndKeyword"/>
      <xsl:copy-of select="$elements-after" copy-namespaces="no" />
    </xsl:copy>
  </xsl:template>

  <!-- Add The conformity keyword to an existing descriptiveKeywords element -->
  <xsl:template name="addKeyword">
    <gmd:descriptiveKeywords>
      <gmd:MD_Keywords>
        <!-- put out each keyword -->
        <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
          <xsl:copy-of copy-namespaces="no" select="."/>
        </xsl:for-each>
        <!-- Add the Conformity keyword -->
        <gmd:keyword>
          <gmx:Anchor xlink:href="{$keywordAnchor}">
            <xsl:value-of select="$keywordString"/>
          </gmx:Anchor>
        </gmd:keyword>
        <!-- do not forget to put out sibling element type -->
        <xsl:for-each select="gmd:MD_Keywords/gmd:type">
          <xsl:copy-of copy-namespaces="no" select="."/>
        </xsl:for-each>
        <xsl:apply-templates select="gmd:type"/>
        <!-- do not forget to put out sibling element thesaurusName -->
        <xsl:for-each select="gmd:MD_Keywords/gmd:thesaurusName">
          <xsl:copy-of copy-namespaces="no" select="."/>
        </xsl:for-each>
      </gmd:MD_Keywords>
    </gmd:descriptiveKeywords>
  </xsl:template>

  <!-- add gmd:descriptiveKeywords using 'GDI-Vlaanderen Trefwoorden' and with the correct conformity keyword -->
  <xsl:template name="addThesaurusAndKeyword">
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
  </xsl:template>
</xsl:stylesheet>
