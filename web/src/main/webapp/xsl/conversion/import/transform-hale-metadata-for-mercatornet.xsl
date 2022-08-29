<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                version="2.0" exclude-result-prefixes="#all">
  <xsl:variable name="hierarchyLevel" select="//gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
  <xsl:variable name="taxonomyThesaurusXlinkHref">http://data.europa.eu/eli/reg/2008/1205</xsl:variable>
  <xsl:variable name="taxonomyThesaurusTitle">Verordening (EG) nr. 1205/2008 van de Commissie van 3 december 2008 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende metagegevens</xsl:variable>

  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy copy-namespaces="no">
      <xsl:call-template name="add-namespaces"/>

      <xsl:apply-templates select="@*[name() != 'xsi:schemaLocation']"/>
      <xsl:attribute name="xsi:schemaLocation"
                     select="'http://www.isotc211.org/2005/gmx http://schemas.opengis.net/iso/19139/20060504/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd'"/>
        <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString[lower-case($hierarchyLevel)='service']" priority="1000">
    <xsl:variable name="serviceType">
      <xsl:value-of select="//gmd:identificationInfo/*/srv:serviceType/gco:LocalName"/>
    </xsl:variable>
    <xsl:variable name="titlePrefix">
      <xsl:choose>
        <xsl:when test="$serviceType='view'">WMS - </xsl:when>
        <xsl:when test="$serviceType='download'">WFS - </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <gco:CharacterString><xsl:value-of select="concat($titlePrefix,.)"/></gco:CharacterString>
  </xsl:template>

  <xsl:template match="gmx:Anchor[ends-with(@xlink:href,'//inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations')]" priority="2000">
    <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations">Geen beperkingen op de publieke toegang.</gmx:Anchor>
  </xsl:template>

  <xsl:template match="gmx:Anchor[ends-with(@xlink:href,'//inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown')]" priority="2000">
    <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown">Deze dataset betreft overheidsinformatie. Indien u deze gegevens wil hergebruiken, dient u zich te wenden tot de eigenaar van de informatie.</gmx:Anchor>
  </xsl:template>

  <xsl:template match="gmx:Anchor[ends-with(@xlink:href,'//inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/noConditionsApply')]" priority="2000">
    <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/noConditionsApply">Geen voorwaarden voor toegang en gebruik.</gmx:Anchor>
  </xsl:template>

  <xsl:template match="gmd:resourceConstraints[name(preceding-sibling::*[1]) != 'gmd:resourceConstraints']" priority="2000">
    <gmd:resourceConstraints>
      <gmd:MD_LegalConstraints>
        <gmd:useConstraints>
          <gmd:MD_RestrictionCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions">otherRestrictions</gmd:MD_RestrictionCode>
        </gmd:useConstraints>
        <gmd:otherConstraints>
          <gmx:Anchor xlink:href="https://overheid.vlaanderen.be/sites/default/files/documenten/ict-egov/licenties/hergebruik/modellicentie_gratis_hergebruik_v1_0.html">In uitvoering van het Vlaamse decreet voor hergebruik van overheidsinformatie, is het hergebruik geregeld d.m.v. de Modellicentie voor gratis hergebruik. Dit betekent dat elk commercieel of niet-commercieel hergebruik voor onebpaalde duur is toegelaten, zonder dat daar kosten aan verbonden zijn. Als enige gebruiksvoorwaarde geldt een bronvermeldingsplicht.</gmx:Anchor>
        </gmd:otherConstraints>
        <gmd:otherConstraints>
          <xsl:variable name="title" select="//gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation/gmd:title[1]/gco:CharacterString"/>
          <xsl:variable name="organisationName" select="//gmd:contact/gmd:CI_ResponsibleParty/gmd:organisationName[1]/gco:CharacterString"/>
          <gco:CharacterString>Verplicht te gebruiken referentie luidt: <xsl:value-of select="$title"/>, <xsl:value-of select="$organisationName"/></gco:CharacterString>
        </gmd:otherConstraints>
        <gmd:otherConstraints>
          <gmx:Anchor xlink:href="https://codex.vlaanderen.be/PrintDocument.ashx?id=1019561">Toegang en gebruik voor het uitvoeren van taken van algemeen belang, op niveau van Vlaamse overheidsinstanties is geregeld door het Besluit van de Vlaamse Regering met de regels voor toegang en gebruik van geografische gegevensbronnen toegevoegd aan de GDI, door deelnemers GDI-Vlaanderen. Dit gebruik is kosteloos.</gmx:Anchor>
        </gmd:otherConstraints>
        <gmd:otherConstraints>
          <gmx:Anchor xlink:href="https://codex.vlaanderen.be/PrintDocument.ashx?id=1020931">Toegang en gebruik voor het uitvoeren van taken van algemeen belang door niet-Vlaamse overheidsinstanties is geregeld door het Besluit van de Vlaamse Regering met de regels voor toegang en gebruik van geografische gegevensbronnen toegevoegd aan de GDI, door overheidsdiensten die geen deelnemer zijn aan GDI-Vlaanderen. Dit gebruik is kosteloos.</gmx:Anchor>
        </gmd:otherConstraints>
      </gmd:MD_LegalConstraints>
    </gmd:resourceConstraints>
    <xsl:if test="count(gmd:MD_LegalConstraints/gmd:useConstraints)=0">
      <xsl:copy copy-namespaces="no">
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:resourceConstraints[count(gmd:MD_LegalConstraints/gmd:useConstraints)>0 and (count(gmd:MD_LegalConstraints/gmd:otherConstraints/gmx:Anchor[ends-with(@xlink:href,'//inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/noConditionsApply') or ends-with(@xlink:href,'//inspire.ec.europa.eu/metadata-codelist/ConditionsApplyingToAccessAndUse/conditionsUnknown')])>0)]" priority="1000"/>

  <xsl:template match="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title='GDI-Vlaanderen Trefwoorden']" priority="1000"/>

  <xsl:template match="gmd:descriptiveKeywords[gmd:MD_Keywords/gmd:keyword/*/normalize-space(.)=('Lijst M&amp;R INSPIRE','Regional','Regionaal','infoMapAccessService','infoFeatureAccessService','infoCatalogueService','infoCoverageAccessService')]" priority="1000"/>

  <xsl:template match="gmd:descriptiveKeywords[name(preceding-sibling::*[1]) != 'gmd:descriptiveKeywords']" priority="2000">
    <xsl:if test="gmd:MD_Keywords/gmd:thesaurusName/gmd:CI_Citation/gmd:title!='GDI-Vlaanderen Trefwoorden' and not(gmd:MD_Keywords/gmd:keyword/*/normalize-space(.)=('Lijst M&amp;R INSPIRE','Regional','Regionaal','infoMapAccessService','infoFeatureAccessService','infoCatalogueService','infoCoverageAccessService'))">
      <xsl:copy-of select="." />
    </xsl:if>
    <gmd:descriptiveKeywords>
      <gmd:MD_Keywords>
        <gmd:keyword>
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/LIJSTMRINSPIRE">Lijst M&amp;R INSPIRE</gmx:Anchor>
        </gmd:keyword>
        <gmd:keyword>
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/HERBRUIKBAAR">Herbruikbaar</gmx:Anchor>
        </gmd:keyword>
        <gmd:keyword>
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/KOSTELOOS">Kosteloos</gmx:Anchor>
        </gmd:keyword>
        <gmd:keyword>
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATA">Vlaamse Open data</gmx:Anchor>
        </gmd:keyword>
        <xsl:if test="lower-case($hierarchyLevel)='service'">
          <gmd:keyword>
            <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/VLOPENDATASERVICE">Vlaamse Open data Service</gmx:Anchor>
          </gmd:keyword>
        </xsl:if>
        <gmd:keyword>
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/TOEGEVOEGDGDIVL">Toegevoegd GDI-Vl</gmx:Anchor>
        </gmd:keyword>
        <gmd:keyword>
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/MDGDICONFORM">Metadata GDI-Vl-conform</gmx:Anchor>
        </gmd:keyword>
        <gmd:keyword>
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/MDINSPIRECONFORM">Metadata INSPIRE-conform</gmx:Anchor>
        </gmd:keyword>
        <gmd:keyword>
          <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/GEODATA">Geografische gegevens</gmx:Anchor>
        </gmd:keyword>
        <gmd:type>
          <gmd:MD_KeywordTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_KeywordTypeCode" codeListValue="theme"/>
        </gmd:type>
        <gmd:thesaurusName>
          <gmd:CI_Citation>
            <gmd:title>
              <gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden">GDI-Vlaanderen Trefwoorden</gmx:Anchor>
            </gmd:title>
            <gmd:date>
              <gmd:CI_Date>
                <gmd:date>
                  <gco:Date>2014-02-26</gco:Date>
                </gmd:date>
                <gmd:dateType>
                  <gmd:CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</gmd:CI_DateTypeCode>
                </gmd:dateType>
              </gmd:CI_Date>
            </gmd:date>
          </gmd:CI_Citation>
        </gmd:thesaurusName>
      </gmd:MD_Keywords>
    </gmd:descriptiveKeywords>
    <xsl:if test="lower-case($hierarchyLevel)!='service'">
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <gmd:keyword>
            <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialScope/regional">Regionaal</gmx:Anchor>
          </gmd:keyword>
          <gmd:type>
            <gmd:MD_KeywordTypeCode
              codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_KeywordTypeCode"
              codeListValue="theme"/>
          </gmd:type>
          <gmd:thesaurusName>
            <gmd:CI_Citation>
              <gmd:title>
                <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialScope">INSPIRE - Spatial scope</gmx:Anchor>
              </gmd:title>
              <gmd:date>
                <gmd:CI_Date>
                  <gmd:date>
                    <gco:Date>2019-05-22</gco:Date>
                  </gmd:date>
                  <gmd:dateType>
                    <gmd:CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</gmd:CI_DateTypeCode>
                  </gmd:dateType>
                </gmd:CI_Date>
              </gmd:date>
            </gmd:CI_Citation>
          </gmd:thesaurusName>
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>
    </xsl:if>
    <xsl:if test="lower-case($hierarchyLevel)='service'">
      <gmd:descriptiveKeywords>
        <gmd:MD_Keywords>
          <gmd:keyword>
            <xsl:choose>
              <xsl:when test="count(../gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/*[contains(.,'infoMapAccessService')])>0">
                <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoMapAccessService">Dienst kaarttoegang</gmx:Anchor>
              </xsl:when>
              <xsl:when test="count(../gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/*[contains(.,'infoFeatureAccessService')])>0">
                <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoFeatureAccessService">Dienst objecttoegang</gmx:Anchor>
              </xsl:when>
              <xsl:when test="count(../gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/*[contains(.,'infoCatalogueService')])>0">
                <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoCatalogueService">Catalogusdienst</gmx:Anchor>
              </xsl:when>
              <xsl:when test="count(../gmd:descriptiveKeywords/gmd:MD_Keywords/gmd:keyword/*[contains(.,'infoCoverageAccessService')])>0">
                <gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoCoverageAccessService">Dienst rastergegevenstoegang</gmx:Anchor>
              </xsl:when>
            </xsl:choose>
          </gmd:keyword>
          <gmd:thesaurusName>
            <gmd:CI_Citation>
              <gmd:title>
                <gmx:Anchor xlink:href="{$taxonomyThesaurusXlinkHref}">
                  <xsl:value-of select="$taxonomyThesaurusTitle"/>
                </gmx:Anchor>
              </gmd:title>
              <gmd:date>
                <gmd:CI_Date>
                  <gmd:date>
                    <gco:Date>2008-12-03</gco:Date>
                  </gmd:date>
                  <gmd:dateType>
                    <gmd:CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</gmd:CI_DateTypeCode>
                  </gmd:dateType>
                </gmd:CI_Date>
              </gmd:date>
            </gmd:CI_Citation>
          </gmd:thesaurusName>
        </gmd:MD_Keywords>
      </gmd:descriptiveKeywords>
    </xsl:if>
  </xsl:template>

  <xsl:template match="gmd:referenceSystemInfo" priority="1000">
    <gmd:referenceSystemInfo>
      <gmd:MD_ReferenceSystem>
        <gmd:referenceSystemIdentifier>
          <gmd:RS_Identifier>
            <gmd:code>
              <gmx:Anchor xlink:href="http://www.opengis.net/def/crs/EPSG/0/3035">EPSG:3035</gmx:Anchor>
            </gmd:code>
          </gmd:RS_Identifier>
        </gmd:referenceSystemIdentifier>
      </gmd:MD_ReferenceSystem>
    </gmd:referenceSystemInfo>
  </xsl:template>

  <xsl:template name="add-namespaces">
    <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
    <xsl:namespace name="gco" select="'http://www.isotc211.org/2005/gco'"/>
    <xsl:namespace name="gmd" select="'http://www.isotc211.org/2005/gmd'"/>
    <xsl:namespace name="gmx" select="'http://www.isotc211.org/2005/gmx'"/>
    <xsl:namespace name="gts" select="'http://www.isotc211.org/2005/gts'"/>
    <xsl:namespace name="gsr" select="'http://www.isotc211.org/2005/gsr'"/>
    <xsl:namespace name="gmi" select="'http://www.isotc211.org/2005/gmi'"/>
    <xsl:if test="lower-case($hierarchyLevel)='service'">
      <xsl:namespace name="srv" select="'http://www.isotc211.org/2005/srv'"/>
    </xsl:if>
    <xsl:namespace name="gml" select="'http://www.opengis.net/gml'"/>
    <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
  </xsl:template>

  <!-- Copy all elements and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
