<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                version="2.0">
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
    match="gmd:DQ_AbsoluteExternalPositionalAccuracy/gmd:measureIdentification |
      gmd:DQ_CompletenessOmission/gmd:measureIdentification |
      gmd:DQ_ThematicClassificationCorrectness/gmd:measureIdentification"
    priority="1000"/>

</xsl:stylesheet>
