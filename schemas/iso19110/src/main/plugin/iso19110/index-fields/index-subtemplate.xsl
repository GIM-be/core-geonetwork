<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gfc="http://www.isotc211.org/2005/gfc"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:util="java:org.fao.geonet.util.XslUtil"
                xmlns:gn-fn-index="http://geonetwork-opensource.org/xsl/functions/index"
                version="2.0">

  <xsl:param name="id"/>
  <xsl:param name="uuid"/>
  <xsl:param name="title"/>

  <xsl:template match="/">
    <Documents>
      <Document locale="">
        <Field name="_title" string="{$title}" store="true" index="true"/>
        <Field name="any" string="{normalize-space(string(.))}" store="false" index="true"/>
        <Field name="_root" string="{name(.)}" store="true" index="true"/>
      </Document>
    </Documents>
  </xsl:template>

</xsl:stylesheet>
