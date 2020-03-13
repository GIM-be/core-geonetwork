<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gml="http://www.opengis.net/gml"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                exclude-result-prefixes="#all">

  <!-- inspireThemes is a nodeset consisting of skos:Concept elements -->
  <!-- each containing a skos:definition and skos:prefLabel for each language -->
  <!-- This template finds the provided keyword in the skos:prefLabel elements and
  returns the English one from the same skos:Concept -->
  <xsl:template name="translateInspireThemeToEnglish">
    <xsl:param name="keyword"/>
    <xsl:param name="inspireThemes"/>

    <xsl:value-of select="$inspireThemes/skos:prefLabel[@xml:lang='en' and ../skos:prefLabel = $keyword]/text()"/>
  </xsl:template>

  <!--xsl:template name="getInspireThemeAcronym">
    <xsl:param name="keyword"/>

    <xsl:value-of select="$inspire-theme/skos:altLabel[../skos:prefLabel = $keyword]/text()"/>
  </xsl:template-->

  <xsl:template name="getInspireThemeAcronym">
    <xsl:param name="keyword"/>
    <xsl:param name="inspireThemes"/>
    <xsl:variable name="englishKeywordMixedCase">
      <xsl:call-template name="translateInspireThemeToEnglish">
        <xsl:with-param name="keyword" select="$keyword"/>
        <xsl:with-param name="inspireThemes" select="$inspireThemes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$englishKeywordMixedCase='Coordinate reference systems'">
        <xsl:text>rs</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Elevation'">
        <xsl:text>el</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Land cover'">
        <xsl:text>lc</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Orthoimagery'">
        <xsl:text>oi</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Geology'">
        <xsl:text>ge</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Statistical units'">
        <xsl:text>su</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Buildings'">
        <xsl:text>bu</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Soil'">
        <xsl:text>so</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Land use'">
        <xsl:text>lu</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Human health and safety'">
        <xsl:text>hh</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Utility and governmental services'">
        <xsl:text>us</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Geographical grid systems'">
        <xsl:text>gg</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Environmental monitoring facilities'">
        <xsl:text>ef</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Production and industrial facilities'">
        <xsl:text>pf</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Agricultural and aquaculture facilities'">
        <xsl:text>af</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Population distribution — demography'">
        <xsl:text>pd</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Area management/restriction/regulation zones and reporting units'">
        <xsl:text>am</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Natural risk zones'">
        <xsl:text>nz</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Atmospheric conditions'">
        <xsl:text>ac</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Meteorological geographical features'">
        <xsl:text>mf</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Oceanographic geographical features'">
        <xsl:text>of</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Sea regions'">
        <xsl:text>sr</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Geographical names'">
        <xsl:text>gn</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Bio-geographical regions'">
        <xsl:text>br</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Habitats and biotopes'">
        <xsl:text>hb</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Species distribution'">
        <xsl:text>sd</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Energy resources'">
        <xsl:text>er</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Mineral resources'">
        <xsl:text>mr</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Administrative units'">
        <xsl:text>au</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Addresses'">
        <xsl:text>ad</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Cadastral parcels'">
        <xsl:text>cp</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Transport networks'">
        <xsl:text>tn</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Hydrography'">
        <xsl:text>hy</xsl:text>
      </xsl:when>
      <xsl:when test="$englishKeywordMixedCase='Protected sites'">
        <xsl:text>ps</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="determineInspireAnnex">
    <xsl:param name="keyword"/>
    <xsl:param name="inspireThemes"/>
    <xsl:variable name="englishKeywordMixedCase">
      <xsl:call-template name="translateInspireThemeToEnglish">
        <xsl:with-param name="keyword" select="$keyword"/>
        <xsl:with-param name="inspireThemes" select="$inspireThemes"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="englishKeyword" select="lower-case($englishKeywordMixedCase)"/>
    <!-- Another option could be to add the annex info in the SKOS thesaurus using something
    like a related concept. -->
    <xsl:choose>
      <!-- annex i -->
      <xsl:when test="$englishKeyword='coordinate reference systems' or $englishKeyword='geographical grid systems'
                                    or $englishKeyword='geographical names' or $englishKeyword='administrative units'
                                    or $englishKeyword='addresses' or $englishKeyword='cadastral parcels'
                                    or $englishKeyword='transport networks' or $englishKeyword='hydrography'
                                    or $englishKeyword='protected sites'">
        <xsl:text>i</xsl:text>
      </xsl:when>
      <!-- annex ii -->
      <xsl:when test="$englishKeyword='elevation' or $englishKeyword='land cover'
                                    or $englishKeyword='orthoimagery' or $englishKeyword='geology'">
        <xsl:text>ii</xsl:text>
      </xsl:when>
      <!-- annex iii -->
      <xsl:when test="$englishKeyword='statistical units' or $englishKeyword='buildings'
                                    or $englishKeyword='soil' or $englishKeyword='land use'
                                    or $englishKeyword='human health and safety' or $englishKeyword='utility and governmental services'
                                    or $englishKeyword='environmental monitoring facilities' or $englishKeyword='production and industrial facilities'
                                    or $englishKeyword='agricultural and aquaculture facilities' or $englishKeyword='population distribution — demography'
                                    or $englishKeyword='area management/restriction/regulation zones and reporting units'
                                    or $englishKeyword='natural risk zones' or $englishKeyword='atmospheric conditions'
                                    or $englishKeyword='meteorological geographical features' or $englishKeyword='oceanographic geographical features'
                                    or $englishKeyword='sea regions' or $englishKeyword='bio-geographical regions'
                                    or $englishKeyword='habitats and biotopes' or $englishKeyword='species distribution'
                                    or $englishKeyword='energy resources' or $englishKeyword='mineral resources'">
        <xsl:text>iii</xsl:text>
      </xsl:when>
      <!-- inspire annex cannot be established: leave empty -->
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
