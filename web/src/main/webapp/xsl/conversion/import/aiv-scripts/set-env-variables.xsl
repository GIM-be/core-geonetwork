<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:gmd="http://www.isotc211.org/2005/gmd"
                version="2.0" exclude-result-prefixes="#all">
  <xsl:variable name="nodeType">Metadatacenter</xsl:variable>
  <xsl:variable name="applicationBaseUrl">https://dev.metadata.vlaanderen.be</xsl:variable>
  <xsl:variable name="hierarchyLevel" select="//gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
  <xsl:variable name="isForInspireReporting" select="count(//gmd:identificationInfo/*/gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/*/contains(lower-case(.),'lijst m'))>0"/>
</xsl:stylesheet>
