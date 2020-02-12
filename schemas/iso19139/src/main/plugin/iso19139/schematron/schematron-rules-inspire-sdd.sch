<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!--
  ~ This Schematron define INSPIRE IR on metadata for Spatial Data Dataset and Datasetseries (SDS)
  ~
  ~     @author Emanuele Tajariol - GeoSolutions, 2016
  ~
  ~ This work is licensed under the Creative Commons Attribution 2.5 License.
  ~ To view a copy of this license, visit
  ~     http://creativecommons.org/licenses/by/2.5/
  ~
  ~ or send a letter to:
  ~
  ~ Creative Commons,
  ~ 543 Howard Street, 5th Floor,
  ~ San Francisco, California, 94105,
  ~ USA.
-->
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            queryBinding="xslt2">

  <sch:title xmlns="http://www.w3.org/2001/XMLSchema">INSPIRE SDD(S) rules</sch:title>

  <sch:ns prefix="gml" uri="http://www.opengis.net/gml"/>
  <sch:ns prefix="gmd" uri="http://www.isotc211.org/2005/gmd"/>
  <sch:ns prefix="gmx" uri="http://www.isotc211.org/2005/gmx"/>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
  <sch:ns prefix="skos" uri="http://www.w3.org/2004/02/skos/core#"/>
  <sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>

  <!-- INSPIRE SDD metadata rules / START -->

  <!-- TG Requirement 4
  For each spatial data dataset or datasetserie, there shall be one and only one set of quality information (dataQualityInfo element) scoped to “dataset” or “series”. -->

  <sch:pattern>
    <sch:title>$loc/strings/tg4</sch:title>

    <sch:rule context="//gmd:MD_Metadata[gmd:identificationInfo/gmd:MD_DataIdentification]">

      <sch:assert
        test="count(gmd:dataQualityInfo/gmd:DQ_DataQuality[gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset' or gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='series'])>0">
        <sch:value-of select="$loc/strings/tg4.missing"/>
      </sch:assert>
      <sch:assert
        test="count(gmd:dataQualityInfo/gmd:DQ_DataQuality[gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset' or gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='series'])&lt;2">
        <sch:value-of select="$loc/strings/tg4.toomany"/>
      </sch:assert>

      <sch:report
        test="count(gmd:dataQualityInfo/gmd:DQ_DataQuality[gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='dataset' or gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode/@codeListValue='series'])=1">
        <sch:value-of select="$loc/strings/tg4.ok"/>
      </sch:report>

    </sch:rule>
  </sch:pattern>

  <!-- INSPIRE SDD metadata rules / END -->

</sch:schema>
