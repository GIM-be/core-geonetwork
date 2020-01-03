<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                version="2.0">

  <xsl:variable name="baseIso19139" select="'../../../WEB-INF/data/config/schema_plugins/iso19139/thesauri-AIV/'"/>

  <xsl:variable name="thesaurusList">
    <path><xsl:value-of select="concat($baseIso19139, 'theme/featureconcept.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/GDI-Vlaanderen-service-types.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/GDI-Vlaanderen-trefwoorden.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/gemet.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/inspire-service-taxonomy.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/inspire-theme.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'theme/PriorityDataset.rdf')"/></path>
    <path><xsl:value-of select="concat($baseIso19139, 'place/GDI-Vlaanderenregios.rdf')"/></path>
  </xsl:variable>

  <xsl:variable name="thesauri">
    <xsl:for-each select="$thesaurusList/path">
      <xsl:variable name="currentDoc" select="document(.)"/>
      <thesausus>
        <xsl:attribute name="title" select="string($currentDoc/rdf:RDF/skos:ConceptScheme/dc:title[1])"/>
        <xsl:copy-of select="$currentDoc/rdf:RDF/skos:Concept"/>
      </thesausus>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="gmd:MD_Keywords[gmd:thesaurusName and gmd:keyword/gco:CharacterString]">
    <xsl:variable name="thesaurusTitle" select="gmd:thesaurusName/gmd:CI_Citation/gmd:title/gco:CharacterString"/>
    <xsl:variable name="currentThesaurus" select="$thesauri/thesausus[@title = $thesaurusTitle]"/>
    <xsl:copy copy-namespaces="no">
      <xsl:for-each select="gmd:keyword">
        <xsl:variable name="keyword" select="gco:CharacterString"/>
        <xsl:variable name="xlink" select="$currentThesaurus/skos:Concept[skos:prefLabel = $keyword][1]/@rdf:about"/>
        <xsl:choose>
          <xsl:when test="gmx:Anchor">
            <xsl:copy-of select="."/>
          </xsl:when>
          <xsl:when test="$xlink">
            <xsl:copy copy-namespaces="no">
              <xsl:element name="gmx:Anchor">
                <xsl:attribute name="xlink:href" select="$xlink"/>
                <xsl:choose>
                  <xsl:when test="$currentThesaurus/skos:Concept[@rdf:about = $xlink]/skos:prefLabel[@xml:lang = 'nl']">
                    <xsl:value-of select="$currentThesaurus/skos:Concept[@rdf:about = $xlink]/skos:prefLabel[@xml:lang = 'nl']"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$keyword"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:element>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:apply-templates select="gmd:thesaurusName"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy>
      <xsl:namespace name="gmd" select="'http://www.isotc211.org/2005/gmd'"/>
      <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
      <xsl:namespace name="gco" select="'http://www.isotc211.org/2005/gco'"/>
      <xsl:namespace name="gml" select="'http://www.opengis.net/gml'"/>
      <xsl:namespace name="geonet" select="'http://www.fao.org/geonetwork'"/>
      <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
      <xsl:namespace name="gmx" select="'http://www.isotc211.org/2005/gmx'"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
