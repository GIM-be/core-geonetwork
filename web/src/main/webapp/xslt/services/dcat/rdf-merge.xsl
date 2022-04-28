<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:geonet="http://www.fao.org/geonetwork"
                xmlns:saxon="http://saxon.sf.net/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:foaf="http://xmlns.com/foaf/0.1/"
                xmlns:void="http://www.w3.org/TR/void/"
                xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
                xmlns:dcat="http://www.w3.org/ns/dcat#"
                xmlns:dct="http://purl.org/dc/terms/"
                xmlns:skos="http://www.w3.org/2004/02/skos/core#"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <xsl:template match="/root">
    <rdf:RDF>
      <xsl:apply-templates select="*[name() != 'gui']"/>
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="rdf:RDF">
    <xsl:apply-templates select="@*|*|text()"/>
  </xsl:template>

  <xsl:template match="dcat:Catalog">
    <xsl:choose>
      <xsl:when test="count(../preceding-sibling::rdf:RDF) = 0">
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*|*|text()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="dcat:record|dcat:CatalogRecord|dcat:dataset|dcat:Dataset|dcat:service|dcat:DataService"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*|*|text()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|*|text()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
