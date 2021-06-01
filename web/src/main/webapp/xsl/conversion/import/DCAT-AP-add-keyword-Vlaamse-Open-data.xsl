<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:mdcat="http://data.vlaanderen.be/ns/metadata-dcat#"
                xmlns:adms="http://www.w3.org/ns/adms#">

  <!-- Copy all other elements -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- If the keyword doesn't exist yet, this template copy every dcat element in the right order and add the missing keyword -->
  <xsl:template match="dcat:Dataset">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="dct:identifier"/>
      <xsl:apply-templates select="dct:title"/>
      <xsl:apply-templates select="dct:description"/>
      <xsl:apply-templates select="dcat:contactPoint"/>
      <xsl:apply-templates select="dct:issued"/>
      <xsl:apply-templates select="dct:modified"/>
      <xsl:apply-templates select="dct:publisher"/>
      <xsl:apply-templates select="dcat:keyword[not(translate(text(), 'abcdefghijklmonpqrstuvwxyz', 'ABCDEFGHIJKLMONPQRSTUVWXYZ') = 'VLAAMSE OPEN DATA')]"/>
      <!-- Add the missing keyword -->
      <dcat:keyword xml:lang="nl">Vlaamse Open data</dcat:keyword>
      <xsl:apply-templates select="dcat:theme"/>
      <xsl:apply-templates select="dct:accessRights"/>
      <xsl:apply-templates select="dct:conformsTo"/>
      <xsl:apply-templates select="foaf:page"/>
      <xsl:apply-templates select="dct:accrualPeriodicity"/>
      <xsl:apply-templates select="dct:hasVersion"/>
      <xsl:apply-templates select="dct:isVersionOf"/>
      <xsl:apply-templates select="dcat:landingPage"/>
      <xsl:apply-templates select="dct:language"/>
      <xsl:apply-templates select="adms:identifier"/>
      <xsl:apply-templates select="dct:provenance"/>
      <xsl:apply-templates select="dct:relation"/>
      <xsl:apply-templates select="dct:source"/>
      <xsl:apply-templates select="dct:spatial"/>
      <xsl:apply-templates select="dct:temporal"/>
      <xsl:apply-templates select="dct:type"/>
      <xsl:apply-templates select="owl:versionInfo"/>
      <xsl:apply-templates select="adms:versionNotes"/>
      <xsl:apply-templates select="dcat:extension"/>
      <xsl:apply-templates select="dcat:distribution"/>
      <xsl:apply-templates select="adms:sample"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="dcat:DataService">
    <dcat:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="dct:identifier"/>
      <xsl:apply-templates select="dct:title"/>
      <xsl:apply-templates select="dct:description"/>
      <xsl:apply-templates select="dct:publisher"/>
      <xsl:apply-templates select="dcat:endpointUrl"/>
      <xsl:apply-templates select="dcat:endpointDescription"/>
      <xsl:apply-templates select="dcat:servesDataset"/>
      <xsl:apply-templates select="dcat:landingPage"/>
      <xsl:apply-templates select="dcat:contactPoint"/>
      <xsl:apply-templates select="dcat:keyword[not(translate(text(), 'abcdefghijklmonpqrstuvwxyz', 'ABCDEFGHIJKLMONPQRSTUVWXYZ') = 'VLAAMSE OPEN DATA')]"/>
      <!-- Add the missing keyword -->
      <dcat:keyword xml:lang="nl">Vlaamse Open data</dcat:keyword>
      <xsl:apply-templates select="dct:language"/>
      <xsl:apply-templates select="owl:versionInfo"/>
      <xsl:apply-templates select="adms:identifier"/>
      <xsl:apply-templates select="mdcat:landingspaginaVoorAuthenticatie"/>
      <xsl:apply-templates select="mdcat:landingspaginaVoorStatusinformatie"/>
      <xsl:apply-templates select="mdcat:landingspaginaVoorGebruiksinformatie"/>
      <xsl:apply-templates select="mdcat:levensfase"/>
      <xsl:apply-templates select="mdcat:ontwikkelingstoestand"/>
      <xsl:apply-templates select="dcat:qualifiedRelation"/>
      <xsl:apply-templates select="dcat:theme"/>
      <xsl:apply-templates select="dct:accessRights"/>
      <xsl:apply-templates select="dct:conformsTo"/>
      <xsl:apply-templates select="dct:creator"/>
      <xsl:apply-templates select="dct:isReferencedBy"/>
      <xsl:apply-templates select="dct:license"/>
      <xsl:apply-templates select="dct:issued"/>
      <xsl:apply-templates select="dct:modified"/>
      <xsl:apply-templates select="dct:relation"/>
      <xsl:apply-templates select="dct:rights"/>
      <xsl:apply-templates select="dct:type"/>
    </dcat:copy>
  </xsl:template>
</xsl:stylesheet>
