<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xslutil="java:org.fao.geonet.util.XslUtil"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                version="2.0">

  <xsl:template name="ExtractLang" match="gmd:language">
    <xsl:param name="lang"/>
    <xsl:choose>
      <xsl:when test="$lang/gmd:LanguageCode/@codeListValue != ''">
        <xsl:value-of select="translate($lang/gmd:LanguageCode/@codeListValue, $uppercase, $lowercase)"/>
      </xsl:when>
      <xsl:when test="$lang/gmd:LanguageCode != ''">
        <xsl:value-of select="translate($lang/gmd:LanguageCode, $uppercase, $lowercase)"/>
      </xsl:when>
      <xsl:when test="$lang/gco:CharacterString != ''">
        <xsl:value-of select="translate($lang/gco:CharacterString, $uppercase, $lowercase)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Alpha3-to-Alpha2">
    <xsl:param name="lang"/>
    <xsl:choose>
      <xsl:when test="$lang = 'bul'">
        <xsl:text>bg</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'cze'">
        <xsl:text>cs</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'dan'">
        <xsl:text>da</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'ger'">
        <xsl:text>de</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'gre'">
        <xsl:text>el</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'eng'">
        <xsl:text>en</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'spa'">
        <xsl:text>es</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'est'">
        <xsl:text>et</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'fin'">
        <xsl:text>fi</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'fre'">
        <xsl:text>fr</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'gle'">
        <xsl:text>ga</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'hrv'">
        <xsl:text>hr</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'ita'">
        <xsl:text>it</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'lav'">
        <xsl:text>lv</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'lit'">
        <xsl:text>lt</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'hun'">
        <xsl:text>hu</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'mlt'">
        <xsl:text>mt</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'dut'">
        <xsl:text>nl</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'pol'">
        <xsl:text>pl</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'por'">
        <xsl:text>pt</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'rum'">
        <xsl:text>ru</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'slo'">
        <xsl:text>sk</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'slv'">
        <xsl:text>sl</xsl:text>
      </xsl:when>
      <xsl:when test="$lang = 'swe'">
        <xsl:text>sv</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lang"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Map-language">
    <xsl:param name="lang"/>
    <xsl:choose>
      <xsl:when test="$lang = 'DUT'">
        <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/NLD">
          <rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
          <skos:prefLabel xml:lang="de">Niederländisch</skos:prefLabel>
          <skos:prefLabel xml:lang="en">Dutch</skos:prefLabel>
          <skos:prefLabel xml:lang="fr">néerlandais</skos:prefLabel>
          <skos:prefLabel xml:lang="nl">Nederlands</skos:prefLabel>
          <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
        </skos:Concept>
      </xsl:when>
      <xsl:when test="$lang = 'ENG'">
        <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/ENG">
          <rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
          <skos:prefLabel xml:lang="de">Englisch</skos:prefLabel>
          <skos:prefLabel xml:lang="en">English</skos:prefLabel>
          <skos:prefLabel xml:lang="fr">anglais</skos:prefLabel>
          <skos:prefLabel xml:lang="nl">Engels</skos:prefLabel>
          <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
        </skos:Concept>
      </xsl:when>
      <xsl:when test="$lang = ('FRE', 'FRA')">
        <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/FRA">
          <rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
          <skos:prefLabel xml:lang="de">Französisch</skos:prefLabel>
          <skos:prefLabel xml:lang="en">French</skos:prefLabel>
          <skos:prefLabel xml:lang="fr">français</skos:prefLabel>
          <skos:prefLabel xml:lang="nl">Frans</skos:prefLabel>
          <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
        </skos:Concept>
      </xsl:when>
      <xsl:when test="$lang = 'GER'">
        <skos:Concept rdf:about="http://publications.europa.eu/resource/authority/language/DEU">
          <rdf:type rdf:resource="http://purl.org/dc/terms/LinguisticSystem"/>
          <skos:prefLabel xml:lang="de">Deutsch</skos:prefLabel>
          <skos:prefLabel xml:lang="en">German</skos:prefLabel>
          <skos:prefLabel xml:lang="fr">allemand</skos:prefLabel>
          <skos:prefLabel xml:lang="nl">Duits</skos:prefLabel>
          <skos:inScheme rdf:resource="http://publications.europa.eu/resource/authority/language"/>
        </skos:Concept>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="Map-format">
    <xsl:param name="protocol"/>
    <xsl:param name="url"/>

    <xsl:choose>
      <xsl:when test="ends-with($protocol, 'get-capabilities')">
        <xsl:value-of select="'application/xml'"/>
      </xsl:when>

      <xsl:when test="ends-with($protocol, 'get-map')">
        <xsl:value-of select="geonet:getQueryParamValue($url, 'format')"/>
      </xsl:when>

      <xsl:when test="ends-with($protocol, 'get-tile')">
        <xsl:value-of select="geonet:getQueryParamValue($url, 'format')"/>
      </xsl:when>

      <xsl:when test="ends-with($protocol, 'get-coverage')">
        <xsl:value-of select="geonet:getQueryParamValue($url, 'format')"/>
      </xsl:when>

      <xsl:when test="ends-with($protocol, 'get-feature')">
        <xsl:variable name="format" select="geonet:getQueryParamValue($url, 'outputFormat')"/>
        <xsl:choose>
          <xsl:when test="$format">
            <xsl:value-of select="$format"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'GML'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:function name="geonet:getQueryParamValue">
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="queryParam" as="xs:string"/>
    <xsl:variable name="value" select="substring-after(lower-case($url), concat(lower-case($queryParam), '='))"/>
    <xsl:value-of
      select="normalize-space(if (contains($value, '&amp;')) then substring-before($value, '&amp;') else $value)"/>
  </xsl:function>


  <xsl:function name="geonet:getElementName">
    <xsl:param name="description" as="node()"/>
    <xsl:variable name="type" select="string($description/rdf:type/@rdf:resource)"/>
    <xsl:choose>
      <xsl:when test="$type = concat($dcat, 'Dataset')">
        <xsl:value-of select="'dcat:Dataset'"/>
      </xsl:when>
      <xsl:when test="$type = concat($dcat, 'DataService')">
        <xsl:value-of select="'dcat:DataService'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message select="concat('WARNING: &quot;', $type, '&quot; does not have an element name')"/>
        <xsl:value-of select="'dcat:Dataset'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="geonet:escapeURI">
    <xsl:param name="uri"/>
    <xsl:if test="$uri">
      <xsl:value-of select="replace(normalize-space($uri), ' ', '%20')"/>
    </xsl:if>
  </xsl:function>

  <xsl:function name="geonet:getLabel">
    <xsl:param name="el"/>
    <xsl:choose>
      <xsl:when test="$el/gmx:Anchor">
        <xsl:value-of select="normalize-space($el/gmx:Anchor)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($el/gco:CharacterString)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="geonet:getResourceUuid">
    <xsl:param name="md" as="node()"/>
    <xsl:variable name="resourceIdentifiers">
      <xsl:for-each select="$md//gmd:identificationInfo[1]/*/gmd:citation/*/gmd:identifier/*">
        <xsl:choose>
          <xsl:when test="gmd:codeSpace/gco:CharacterString/text() != ''">
            <xsl:value-of select="concat(gmd:codeSpace/gco:CharacterString/text(), gmd:code/gco:CharacterString/text())"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="gmd:code/gco:CharacterString/text()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$resourceIdentifiers[matches(., $uuidRegex)][1]">
        <xsl:value-of select="$resourceIdentifiers[matches(., $uuidRegex)][1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="xslutil:uuidFromString($md//gmd:fileIdentifier/gco:CharacterString)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
