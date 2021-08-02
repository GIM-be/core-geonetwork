<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:variable name="dataTheme" select="document('../thesauri-AIV/theme/datatheme.rdf')"/>

  <xsl:template name="MapTopicCatToDataGovTheme">
    <xsl:param name="TopicCategory" as="xs:string"/>
    <xsl:variable name="the" select="'http://vocab.belgif.be/auth/datatheme'"/>
    <xsl:variable name="govTheme">
      <xsl:choose>
        <xsl:when test="$TopicCategory = 'farming'">
          <xsl:value-of select="'AGRI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'biota'">
          <xsl:value-of select="'ENVI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'boundaries'">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'climatologyMeteorologyAtmosphere'">
          <xsl:value-of select="'ENVI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'economy'">
          <xsl:value-of select="'ECON'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'elevation'">
          <xsl:value-of select="'ENVI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'environment'">
          <xsl:value-of select="'ENVI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'geoscientificInformation'">
          <xsl:value-of select="'TECH'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'health'">
          <xsl:value-of select="'HEAL'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'imageryBaseMapsEarthCover'">
          <xsl:value-of select="'ENVI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'intelligenceMilitary'">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'inlandWaters'">
          <xsl:value-of select="'ENVI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'location'">
          <xsl:value-of select="'ENVI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'oceans'">
          <xsl:value-of select="'ENVI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'planningCadastre'">
          <xsl:value-of select="'ENVI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'society'">
          <xsl:value-of select="'SOCI'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'structure'">
          <xsl:value-of select="''"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'transportation'">
          <xsl:value-of select="'TRAN'"/>
        </xsl:when>
        <xsl:when test="$TopicCategory = 'utilitiesCommunication'">
          <xsl:value-of select="''"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:if test="$govTheme != ''">
      <dcat:theme>
        <skos:Concept>
          <xsl:attribute name="rdf:about" select="concat($the, '/', $govTheme)"/>
          <xsl:for-each select="$dataTheme/rdf:RDF/skos:Concept[@rdf:about = concat($the, '/', $govTheme)]/skos:prefLabel">
            <xsl:element name="skos:prefLabel">
              <xsl:attribute name="xml:lang" select="@xml:lang"/>
              <xsl:value-of select="string()"/>
            </xsl:element>
          </xsl:for-each>
          <skos:inScheme rdf:resource="{$the}"/>
        </skos:Concept>
      </dcat:theme>
    </xsl:if>
  </xsl:template>

  <xsl:template name="MapTopicCatToDataGovThemeTitle">
    <xsl:param name="TopicCategory" as="xs:string"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:variable name="theme">
      <xsl:call-template name="MapTopicCatToDataGovTheme">
        <xsl:with-param name="TopicCategory" select="$TopicCategory"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$theme/dcat:theme/skos:Concept/skos:prefLabel[@xml:lang = $lang]/text()"/>
  </xsl:template>
</xsl:stylesheet>
