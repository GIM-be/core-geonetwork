<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:xslUtils="java:org.fao.geonet.util.XslUtil"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <xsl:include href="./min-utility-fn.xsl"/>
  <xsl:include href="./variables.xsl"/>
  <xsl:include href="./starting-point.xsl"/>


  <!-- Content templates -->
  <!-- Responsible the order of the elements -->
  <xsl:template mode="render-content" match="gmd:MD_Metadata">
    <xsl:apply-templates select="gmd:identificationInfo" mode="render-content"/>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:identificationInfo">
    <xsl:call-template name="render-title">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
    </xsl:call-template>
    <xsl:call-template name="render-block">
      <xsl:with-param name="block">
        <xsl:copy-of select="gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title"/>
        <xsl:copy-of select="gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:CharacterString]">
    <xsl:call-template name="render-text-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="string()"/>
    </xsl:call-template>
  </xsl:template>


  <!-- Renderer templates -->
  <!-- Responsible for the layout -->
  <xsl:template name="render-block">
    <xsl:param name="block" as="node()"/>
    <table class="table table-striped">
      <tbody>
        <xsl:apply-templates select="$block" mode="render-content"/>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template name="render-title">
    <xsl:param name="label" as="xs:string"/>
    <xsl:element name="h2">
      <xsl:attribute name="data-translate"/>
      <xsl:value-of select="normalize-space($label)"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="render-text-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="value" as="xs:string"/>
    <tr>
      <th>
        <xsl:value-of select="$label"/>
      </th>
      <td>
        <xsl:value-of select="$value"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
