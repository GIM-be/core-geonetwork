<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

  <xsl:template name="MapTopicCatToDataGov">
    <xsl:param name="TopicCategory" as="xs:string"/>
    <xsl:variable name="thes" select="'http://vocab.belgif.be/auth/datatheme/'"/>
    <xsl:variable name="theme">
      <dcat:theme>
        <skos:Concept>
          <xsl:choose>
            <xsl:when test="$TopicCategory = 'farming'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'biota'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'boundaries'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'climatologyMeteorologyAtmosphere'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'economy'">
              <xsl:attribute name="rdf:about" select="concat($thes, 'ECON')"/>
              <skos:prefLabel xml:lang="nl">Economie en financiën</skos:prefLabel>
              <skos:prefLabel xml:lang="en">Economy and finance</skos:prefLabel>
              <skos:prefLabel xml:lang="de">Wirtschaft und Finanzen</skos:prefLabel>
              <skos:prefLabel xml:lang="fr">Économie et finances</skos:prefLabel>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'elevation'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'environment'">
              <xsl:attribute name="rdf:about" select="concat($thes, 'ENVI')"/>
              <skos:prefLabel xml:lang="en">Environment</skos:prefLabel>
              <skos:prefLabel xml:lang="fr">Environnement</skos:prefLabel>
              <skos:prefLabel xml:lang="nl">Milieu</skos:prefLabel>
              <skos:prefLabel xml:lang="de">Umwelt</skos:prefLabel>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'geoscientificInformation'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'health'">
              <xsl:attribute name="rdf:about" select="concat($thes, 'HEAL')"/>
              <skos:prefLabel xml:lang="de">Gesundheit</skos:prefLabel>
              <skos:prefLabel xml:lang="nl">Gezondheid</skos:prefLabel>
              <skos:prefLabel xml:lang="en">Health</skos:prefLabel>
              <skos:prefLabel xml:lang="fr">Santé</skos:prefLabel>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'imageryBaseMapsEarthCover'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'intelligenceMilitary'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'inlandWaters'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'location'">
              <xsl:attribute name="rdf:about" select="concat($thes, 'REGI')"/>
              <skos:prefLabel xml:lang="fr">Gouvernement et secteur public</skos:prefLabel>
              <skos:prefLabel xml:lang="en">Government and public sector</skos:prefLabel>
              <skos:prefLabel xml:lang="nl">Overheid en publieke sector</skos:prefLabel>
              <skos:prefLabel xml:lang="de">Regierung und öffentlicher Sektor</skos:prefLabel>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'oceans'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'planningCadastre'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'society'">
              <xsl:attribute name="rdf:about" select="concat($thes, 'SOCI')"/>
              <skos:prefLabel xml:lang="nl">Bevolking en samenleving</skos:prefLabel>
              <skos:prefLabel xml:lang="de">Bevölkerung und Gesellschaft</skos:prefLabel>
              <skos:prefLabel xml:lang="en">Population and society</skos:prefLabel>
              <skos:prefLabel xml:lang="fr">Population et société</skos:prefLabel>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'structure'">
              <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'transportation'">
              <xsl:attribute name="rdf:about" select="concat($thes, 'TRAN')"/>
              <skos:prefLabel xml:lang="en">Transport</skos:prefLabel>
              <skos:prefLabel xml:lang="fr">Transports</skos:prefLabel>
              <skos:prefLabel xml:lang="de">Verkehr</skos:prefLabel>
              <skos:prefLabel xml:lang="nl">Vervoer</skos:prefLabel>
            </xsl:when>
            <xsl:when test="$TopicCategory = 'utilitiesCommunication'">
              <xsl:value-of select="''"/>
            </xsl:when>
          </xsl:choose>
          <skos:inScheme rdf:resource="http://vocab.belgif.be/auth/datatheme"/>
        </skos:Concept>
      </dcat:theme>
    </xsl:variable>

    <xsl:if test="$theme/dcat:theme/skos:Concept/@rdf:about">
      <xsl:copy-of select="$theme"/>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
