<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0" exclude-result-prefixes="#all">
  <!--
    Templates for removing optional or deprecated elements in the element gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report
  -->

  <xsl:template
    match="gmd:DQ_DomainConsistency/gmd:measureIdentification |
      gmd:DQ_DomainConsistency/gmd:measureDescription |
      gmd:DQ_DomainConsistency/gmd:dateTime |
      gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:alternateTitle"
    priority="1000"/>

  <xsl:template
    match="gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:explanation[@gco:nilReason='missing' or gco:CharacterString='']"
    priority="1000">
    <xsl:copy copy-namespaces="no">
      <gco:CharacterString>Geharmoniseerd volgens INSPIRE verordening</gco:CharacterString>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template
    match="gmd:DQ_AbsoluteExternalPositionalAccuracy/gmd:measureIdentification |
      gmd:DQ_CompletenessOmission/gmd:measureIdentification |
      gmd:DQ_CompletenessCommission/gmd:measureIdentification |
      gmd:DQ_ThematicClassificationCorrectness/gmd:measureIdentification"
    priority="1000"/>

  <xsl:template
    match="gmd:specification/gmd:CI_Citation/gmd:title" priority="1000">
    <xsl:copy copy-namespaces="no">
      <xsl:variable name="specification" select="replace(*[name()=('gco:CharacterString','gmx:Anchor')],'\s',' ')" />
      <xsl:choose>
        <xsl:when test="$specification='VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens'"><gmx:Anchor xlink:href="http://data.europa.eu/eli/reg/2010/1089">VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</gmx:Anchor></xsl:when>
        <xsl:when test="$specification='VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens.'"><gmx:Anchor xlink:href="http://data.europa.eu/eli/reg/2010/1089">VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</gmx:Anchor></xsl:when>
        <xsl:when test="$specification='D2.8.III.11 Data Specification on Area Management/Restriction/Regulation Zones and Reporting Units – Technical Guidelines'"><gmx:Anchor xlink:href="https://inspire.ec.europa.eu/id/document/tg/am">INSPIRE Data Specification on Area Management/Restriction/Regulation Zones and Reporting Units - Technical Guidelines</gmx:Anchor></xsl:when>
        <xsl:when test="$specification='D2.8.I.8 Data Specification on Hydrography – Technical Guidelines'"><gmx:Anchor xlink:href="https://inspire.ec.europa.eu/id/document/tg/hy">INSPIRE Data Specification on Hydrography – Technical Guidelines</gmx:Anchor></xsl:when>
        <xsl:when test="$specification='D2.8.I.7 Data Specification on Transport Networks – Technical Guidelines'"><gmx:Anchor xlink:href="https://inspire.ec.europa.eu/id/document/tg/tn">INSPIRE Data Specification on Transport Networks – Technical Guidelines</gmx:Anchor></xsl:when>
        <xsl:when test="$specification='D2.8.III.2 INSPIRE Data Specification on Buildings - Technical Guidelines'"><gmx:Anchor xlink:href="https://inspire.ec.europa.eu/id/document/tg/bu">INSPIRE Data Specification on Buildings - Technical Guidelines</gmx:Anchor></xsl:when>
        <xsl:when test="$specification='D2.8.I.5 INSPIRE Data Specification on Addresses - Technical Guidelines'"><gmx:Anchor xlink:href="https://inspire.ec.europa.eu/id/document/tg/ad">INSPIRE Data Specification on Addresses – Technical Guidelines</gmx:Anchor></xsl:when>
        <xsl:when test="$specification='D2.8.II/III.7 Data Specification on Environtmental Monitoring Facilities – Technical Guidelines'"><gmx:Anchor xlink:href="https://inspire.ec.europa.eu/id/document/tg/ef">INSPIRE Data Specification on Environmental Monitoring Facilities - Technical Guidelines</gmx:Anchor></xsl:when>
        <xsl:when test="$specification='D2.8.II.3 Data Specification on Orthoimagery – Technical Guidelines'"><gmx:Anchor xlink:href="https://inspire.ec.europa.eu/id/document/tg/oi">INSPIRE Data Specification on Orthoimagery – Technical Guidelines</gmx:Anchor></xsl:when>
        <xsl:when test="$specification='D2.8.II.1 Data Specification on Elevation – Technical Guidelines'"><gmx:Anchor xlink:href="https://inspire.ec.europa.eu/id/document/tg/el">INSPIRE Data Specification on Elevation - Technical Guidelines</gmx:Anchor></xsl:when>
        <xsl:otherwise>
          <xsl:message select="concat('The gmd:specification ',$specification,' is not transformed')" />
          <xsl:apply-templates select="@*|node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
