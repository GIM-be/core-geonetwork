<?xml version="1.0" encoding="UTF-8"?>

<xsl:transform xmlns:dc     = "http://purl.org/dc/elements/1.1/"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:rdf    = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
               xmlns:skos   = "http://www.w3.org/2004/02/skos/core#"
               xmlns:xsl    = "http://www.w3.org/1999/XSL/Transform"
               exclude-result-prefixes="#all"
               version="2.0">

  <xsl:variable name="thesaurusList">
    <path><xsl:value-of select="'../thesauri-AIV/theme/featureconcept.rdf'"/></path>
    <path><xsl:value-of select="'../thesauri-AIV/theme/GDI-Vlaanderen-service-types.rdf'"/></path>
    <path><xsl:value-of select="'../thesauri-AIV/theme/GDI-Vlaanderen-trefwoorden.rdf'"/></path>
    <path><xsl:value-of select="'../thesauri-AIV/theme/gemet.rdf'"/></path>
    <path><xsl:value-of select="'../thesauri-AIV/theme/inspire-service-taxonomy.rdf'"/></path>
    <path><xsl:value-of select="'../thesauri-AIV/theme/inspire-theme.rdf'"/></path>
    <path><xsl:value-of select="'../thesauri-AIV/theme/PriorityDataset.rdf'"/></path>
    <path><xsl:value-of select="'../thesauri-AIV/theme/SpatialScope.rdf'"/></path>
    <path><xsl:value-of select="'../thesauri-AIV/place/GDI-Vlaanderenregios.rdf'"/></path>
  </xsl:variable>

  <xsl:variable name="thesauri">
    <xsl:for-each select="$thesaurusList/path">
      <xsl:variable name="currentDoc" select="document(.)"/>
      <thesausus>
        <xsl:attribute name="title" select="string($currentDoc/rdf:RDF/skos:ConceptScheme/dc:title[1])"/>
        <xsl:attribute name="about" select="string($currentDoc/rdf:RDF/skos:ConceptScheme/@rdf:about)"/>
        <xsl:for-each select="$currentDoc/rdf:RDF//skos:Concept">
          <xsl:copy copy-namespaces="no">
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="skos:prefLabel[@xml:lang = ('en','de','nl','fr')]"/>
          </xsl:copy>
        </xsl:for-each>
        <xsl:for-each select="$currentDoc/rdf:RDF//rdf:Description">
          <skos:Concept>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="skos:prefLabel[@xml:lang = ('en','de','nl','fr')]"/>
          </skos:Concept>
        </xsl:for-each>
      </thesausus>
    </xsl:for-each>
  </xsl:variable>

  <xsl:template name="GetAboutFromCharacterString">
    <xsl:param name="keyword" as="xs:string"/>
    <xsl:param name="thesaurusIdentifier" as="xs:string"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:variable name="thesaurus" select="$thesauri/thesausus[@title = $thesaurusIdentifier or @about = $thesaurusIdentifier]"/>
    <xsl:value-of select="string($thesaurus/skos:Concept[skos:prefLabel[@xml:lang = $lang] = $keyword][1]/@rdf:about)"/>
  </xsl:template>

  <xsl:template name="GetSchemeFromThesaurusTitle">
    <xsl:param name="thesaurusTitle" as="xs:string"/>
    <xsl:value-of select="string($thesauri/thesausus[@title = $thesaurusTitle]/@about)"/>
  </xsl:template>
</xsl:transform>
