<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
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

<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<sch:title xmlns="http://www.w3.org/2001/XMLSchema">ISO rules</sch:title>
  <sch:ns prefix="gco" uri="http://www.isotc211.org/2005/gco"/>
  <sch:ns prefix="gfc" uri="http://www.isotc211.org/2005/gfc"/>
	<sch:ns prefix="gmx" uri="http://www.isotc211.org/2005/gmx"/>
	<sch:ns prefix="geonet" uri="http://www.fao.org/geonetwork"/>
	<sch:ns prefix="xlink" uri="http://www.w3.org/1999/xlink"/>

    <sch:pattern>
        <sch:title>$loc/strings/requiredElements</sch:title>
        <sch:rule context="/*/gmx:versionDate|/*/gfc:versionDate">
          <sch:let name="date" value="gco:Date/text()"/>
          <sch:let name="dateStamp" value="*/text()"/>
          <sch:assert test="$date">
            <sch:value-of select="$loc/strings/alert.requiredDate"/>
          </sch:assert>
          <sch:report test="$date">
            <sch:value-of select="concat($loc/strings/report.requiredDate, ': ', $dateStamp)"/>
          </sch:report>
        </sch:rule>
    </sch:pattern>
</sch:schema>
