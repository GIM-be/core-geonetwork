<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx">

  <!-- match descriptiveKeywords elements -->
  <xsl:template match="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:descriptiveKeywords" priority="1000">
    <xsl:call-template name="removeKeyword"/>
  </xsl:template>

  <xsl:template name="removeKeyword">
    <xsl:choose>
      <!-- this descriptiveKeywords uses 'GDI-Vlaanderen Trefwoorden'  -->
      <xsl:when
        test="gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title[gco:CharacterString = $thesaurusTitle or gmx:Anchor = $thesaurusTitle]">
        <xsl:choose>
          <!-- contains a keyword matching  'Metadata INSPIRE-conform' -->
          <xsl:when
            test="gmd:MD_Keywords//gmd:keyword[lower-case(gco:CharacterString) = $keywordToBeRemovedLowerCase or lower-case(gmx:Anchor) = $keywordToBeRemovedLowerCase]">
            <!-- if there are other keywords, put them out -->
            <xsl:if test="count(gmd:MD_Keywords/gmd:keyword[lower-case(gco:CharacterString) != $keywordToBeRemovedLowerCase and lower-case(gmx:Anchor) != $keywordToBeRemovedLowerCase]) > 0">
              <gmd:descriptiveKeywords>
                <gmd:MD_Keywords>
                  <xsl:for-each select="gmd:MD_Keywords/gmd:keyword">
                    <xsl:choose>
                      <!-- do not put out -->
                      <xsl:when
                        test="lower-case(gco:CharacterString) = $keywordToBeRemovedLowerCase or lower-case(gmx:Anchor) = $keywordToBeRemovedLowerCase"/>
                      <xsl:otherwise>
                        <gmd:keyword>
                          <xsl:apply-templates select="@*|node()"/>
                        </gmd:keyword>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                  <!-- do not forget to put out sibling element type -->
                  <xsl:for-each select="gmd:MD_Keywords/gmd:type">
                    <xsl:copy-of copy-namespaces="no" select="."/>
                  </xsl:for-each>
                  <!-- do not forget to put out sibling element thesaurusName -->
                  <xsl:for-each select="gmd:MD_Keywords/gmd:thesaurusName">
                    <xsl:copy-of select="." copy-namespaces="no" />
                  </xsl:for-each>
                </gmd:MD_Keywords>
              </gmd:descriptiveKeywords>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <!-- does not contain a keyword matching  'Metadata INSPIRE-conform' : just put out-->
            <gmd:descriptiveKeywords>
              <xsl:apply-templates select="@*|node()"/>
            </gmd:descriptiveKeywords>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- descriptiveKeywords not using 'GDI-Vlaanderen Trefwoorden' : just put out -->
      <xsl:otherwise>
        <gmd:descriptiveKeywords>
          <xsl:apply-templates select="@*|node()"/>
        </gmd:descriptiveKeywords>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
