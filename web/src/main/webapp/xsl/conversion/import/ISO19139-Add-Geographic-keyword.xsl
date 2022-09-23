<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0">

  <xsl:template match="gmd:MD_DataIdentification|srv:SV_ServiceIdentification">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:variable name="elements-after"
                    select="gmd:descriptiveKeywords|
                          gmd:resourceSpecificUsage|
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

      <xsl:apply-templates select="* except $elements-after" />

      <xsl:for-each select="gmd:descriptiveKeywords">
        <xsl:copy copy-namespaces="no">
          <xsl:choose>
            <xsl:when test="gmd:MD_Keywords[gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1] = 'GDI-Vlaanderen Trefwoorden']">
              <xsl:for-each select="gmd:MD_Keywords">
                <xsl:copy copy-namespaces="no">
                  <xsl:for-each select="gmd:keyword">
                    <xsl:choose>
                      <xsl:when test="gmx:Anchor/@xlink:href = 'https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/GEODATA' or string(gco:CharacterString|gmx:Anchor) = 'Geografische gegevens'">
                        <gmd:keyword>
                          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/GEODATA">Geografische gegevens</gmx:Anchor>
                        </gmd:keyword>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:copy>
                          <xsl:apply-templates select="@*|*|text()"/>
                        </xsl:copy>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>

                  <xsl:if test="not(gmd:keyword/*[@xlink:href = 'https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/GEODATA' or string() = 'Geografische gegevens'])">
                    <gmd:keyword>
                      <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/GEODATA">Geografische gegevens</gmx:Anchor>
                    </gmd:keyword>
                  </xsl:if>
                  <xsl:apply-templates select="@*|text()|*[name() != 'gmd:keyword']"/>
                </xsl:copy>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="@*|*"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:copy>
      </xsl:for-each>

      <xsl:if test="not(gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[1] = 'GDI-Vlaanderen Trefwoorden'])">
        <gmd:descriptiveKeywords>
          <gmd:MD_Keywords>
            <gmd:keyword>
              <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/GEODATA">Geografische gegevens</gmx:Anchor>
            </gmd:keyword>
            <gmd:thesaurusName>
              <gmd:CI_Citation>
                <gmd:title>
                  <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden">GDI-Vlaanderen Trefwoorden</gmx:Anchor>
                </gmd:title>
                <gmd:date>
                  <gmd:CI_Date>
                    <gmd:date>
                      <gco:Date>2014-02-26</gco:Date>
                    </gmd:date>
                    <gmd:dateType>
                      <gmd:CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</gmd:CI_DateTypeCode>
                    </gmd:dateType>
                  </gmd:CI_Date>
                </gmd:date>
              </gmd:CI_Citation>
            </gmd:thesaurusName>
          </gmd:MD_Keywords>
        </gmd:descriptiveKeywords>
      </xsl:if>

      <xsl:apply-templates select="$elements-after[name() != 'gmd:descriptiveKeywords']" />
    </xsl:copy>
  </xsl:template>



  <xsl:template match="@*|*|text()">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
