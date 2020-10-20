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
<xsl:stylesheet
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wms="http://www.opengis.net/wms"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xmlns:gml="http://www.opengis.net/gml/3.2"
                version="1.0"
    xmlns="http://www.isotc211.org/2005/gmd">
    
    <!-- ============================================================================= -->
	<!-- Waarde wordt afgekapt na EPSG: voor de voorstellingen EPSG:31370 en urn:ogc:def:crs:EPSG:31370
	daarna wordt het afgekapte deel getest op de aanwezigheid van een ':' omdat voor WMTS volgende waarde aanwezig is: urn:ogc:def:crs:EPSG:6.3:4326
	indien er ':' aanwezig is wordt dit nogmaals afgekapt
	het overgebleven deel wordt dan achter de basis URL geplakt-->    
    
    <xsl:template match="*" mode="RefSystemTypes">
		<xsl:variable name="CRS">
			<xsl:value-of select="substring-after(., 'EPSG:')"/>
		</xsl:variable>
		<xsl:variable name="CRS2">
			<xsl:choose>
				<xsl:when test="contains($CRS,':')">
					<xsl:value-of select="substring-after($CRS,':')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$CRS"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="URL">
			<xsl:value-of select="concat('http://www.opengis.net/def/crs/EPSG/0/', $CRS2)"/>
		</xsl:variable>
		<referenceSystemIdentifier>
			<RS_Identifier>
				<code>
					<gmx:Anchor xlink:href="{$URL}"><xsl:value-of select="document($URL)//gml:name"/>
					</gmx:Anchor>
				</code>
			</RS_Identifier>
		</referenceSystemIdentifier>
	</xsl:template>
    <!-- ============================================================================= -->
</xsl:stylesheet>
