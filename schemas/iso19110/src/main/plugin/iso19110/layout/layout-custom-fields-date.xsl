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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gfc="http://www.isotc211.org/2005/gfc"
                xmlns:gn="http://www.fao.org/geonetwork"
                xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata"
                xmlns:gn-fn-iso19110="http://geonetwork-opensource.org/xsl/functions/profiles/iso19110"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                version="2.0"
                exclude-result-prefixes="#all">
  <!--
  Date with not date type.
   eg. editionDate
  -->
  <xsl:template mode="mode-iso19110"
                priority="200"
                match="gmx:versionDate|gfc:versionDate">
    <xsl:param name="schema" select="$schema" required="no"/>
    <xsl:param name="labels" select="$labels" required="no"/>
    <xsl:param name="overrideLabel" select="''" required="no"/>

    <xsl:variable name="xpath" select="gn-fn-metadata:getXPath(.)"/>
    <xsl:variable name="tooltip" select="concat($schema, '|', name(.), '|', name(..), '|', $xpath)"/>
    <xsl:variable name="isoType" select="if (../@gco:isoType) then ../@gco:isoType else ''"/>
    <xsl:variable name="labelConfig"
                  select="gn-fn-metadata:getLabel($schema, name(), $labels, name(..), $isoType, $xpath)"/>
    <xsl:variable name="dateTypeElementRef"
                  select="gn:element/@ref"/>

    <xsl:variable name="isRequired" select="gn:element/@min = 1"/>
    <div class="form-group gn-field gn-date {if ($isRequired) then 'gn-required' else ''}"
         id="gn-el-{$dateTypeElementRef}"
         data-gn-field-highlight="">
      <label class="col-sm-2 control-label">
        <xsl:choose>
          <xsl:when test="$overrideLabel != ''">
            <xsl:value-of select="$overrideLabel"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$labelConfig/label"/>
          </xsl:otherwise>
        </xsl:choose>
      </label>
      <xsl:variable name="bMissingChild" select="not(gco:Date|gco:DateTime)"/>
      <xsl:variable name="newElement">
        <xsl:if test="$bMissingChild">
          <xsl:element name="gco:DateTime" />
        </xsl:if>
      </xsl:variable>
      <div class="col-sm-9 col-xs-11 gn-value nopadding-in-table">
        <div data-gn-date-picker="{if (bMissingChild) then $newElement else (gco:Date|gco:DateTime)}"
             data-gn-field-tooltip="{$tooltip}"
             data-label=""
             data-element-name="{if (bMissingChild) then name($newElement) else name(gco:Date|gco:DateTime)}"
             data-element-ref="{concat('_X', gn:element/@ref)}"
             data-hide-time="{if ($viewConfig/@hideTimeInCalendar = 'true' and not(($bMissingChild and $newElement/name(*[1])='gco:DateTime') or gco:DateTime)) then 'true' else 'false'}">
        </div>


        <!-- Create form for all existing attribute (not in gn namespace)
         and all non existing attributes not already present. -->
        <div class="well well-sm gn-attr {if ($isDisplayingAttributes = true()) then '' else 'hidden'}">
          <xsl:apply-templates mode="render-for-field-for-attribute"
                               select="
            ../../@*|
            ../../gn:attribute[not(@name = parent::node()/@*/name())]">
            <xsl:with-param name="ref" select="../../gn:element/@ref"/>
            <xsl:with-param name="insertRef" select="../gn:element/@ref"/>
          </xsl:apply-templates>
        </div>
      </div>
      <div class="col-sm-1 col-xs-1 gn-control">
        <xsl:call-template name="render-form-field-control-remove">
          <xsl:with-param name="editInfo" select="gn:element"/>
        </xsl:call-template>
      </div>

      <div class="col-sm-offset-2 col-sm-9">
        <xsl:call-template name="get-errors"/>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>
