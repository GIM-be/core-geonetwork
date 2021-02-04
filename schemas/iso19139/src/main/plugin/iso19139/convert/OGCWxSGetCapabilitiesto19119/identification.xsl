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
<!--	xmlns:wcs="http://www.opengis.net/wcs" -->
<xsl:stylesheet xmlns="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:wfs="http://www.opengis.net/wfs" xmlns:ows="http://www.opengis.net/ows" xmlns:ows11="http://www.opengis.net/ows/1.1" xmlns:ows2="http://www.opengis.net/ows/2.0" xmlns:wcs="http://www.opengis.net/wcs/2.0" xmlns:wms="http://www.opengis.net/wms" xmlns:wmts="http://www.opengis.net/wmts/1.0" xmlns:wps="http://www.opengeospatial.net/wps" xmlns:wps1="http://www.opengis.net/wps/1.0.0" xmlns:wps2="http://www.opengis.net/wps/2.0" xmlns:gml="http://www.opengis.net/gml" xmlns:math="http://exslt.org/math" xmlns:exslt="http://exslt.org/common" xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" xmlns:inspire_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0" xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0" xmlns:gmx="http://www.isotc211.org/2005/gmx" xmlns:theme="http://inspire.ec.europa.eu/theme_register" xmlns:grg="http://www.isotc211.org/2005/grg" version="2.0" extension-element-prefixes="math exslt wcs ows ows11 ows2 wps wps1 wps2 wfs gml inspire_common inspire_vs" exclude-result-prefixes="#all">
	<!--variabelen gebruikt in template Keywords-->
	<xsl:variable name="gdi-vlaanderen-regios-thesaurus" select="'GDI-Vlaanderen regio''s'"/>
	<xsl:variable name="gdi-vlaanderen-regios-thesaurus-anchor-href" select="'https://'"/>
	<xsl:variable name="gdi-vlaanderen-regios-thesaurus-anchor-value" select="'Regios'"/>
	<xsl:variable name="gdi-vlaanderen-service-types-thesaurus" select="'GDI-Vlaanderen Service Types'"/>
	<!--	PETER:old value	<xsl:variable name="gdi-vlaanderen-service-types-thesaurus-anchor-href" select="'https://www.geopunt.be/voor-experts/metadata/metadata-best-practices-en-richtlijnen'"/>-->
	<xsl:variable name="gdi-vlaanderen-service-types-thesaurus-anchor-href" select="'https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Service-Types'"/>
	<xsl:variable name="gdi-vlaanderen-service-types-thesaurus-anchor-value" select="'GDI-Vlaanderen Service Types'"/>
	<xsl:variable name="gdi-vlaanderen-trefwoorden-thesaurus" select="'GDI-Vlaanderen Trefwoorden'"/>
	<!-- PETER: old value	<xsl:variable name="gdi-vlaanderen-trefwoorden-thesaurus-anchor-href" select="'https://www.geopunt.be/voor-experts/metadata/metadata-best-practices-en-richtlijnen'"/> -->
	<xsl:variable name="gdi-vlaanderen-trefwoorden-thesaurus-anchor-href" select="'https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden'"/>
	<xsl:variable name="gdi-vlaanderen-trefwoorden-thesaurus-anchor-value" select="'GDI-Vlaanderen Trefwoorden'"/>
	<!--????????-->
	<xsl:variable name="gemet-thesaurus" select="'GEMET - Concepten, versie 2.4'"/>
	<xsl:variable name="gemet-thesaurus-anchor-href" select="'https://'"/>
	<xsl:variable name="gemet-thesaurus-anchor-value" select="'GEMET - Concepten, versie 2.4'"/>
	<xsl:variable name="inspire-service-taxonomy-thesaurus" select="'D.4 van de verordening (EG) NR. 1205/2008 van de Commissie'"/>
	<xsl:variable name="inspire-service-taxonomy-thesaurus-anchor-href" select="'http://data.europa.eu/eli/reg/2008/1205'"/>
	<xsl:variable name="inspire-service-taxonomy-thesaurus-anchor-value" select="'Verordening (EG) nr. 1205/2008 van de Commissie van 3 december 2008 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende metagegevens'"/>
	<!--oorspronkelijk-->
	<!--
	<xsl:variable name="inspire-theme-thesaurus" select="'GEMET - INSPIRE thema''s, versie 1.0'"/>
	<xsl:variable name="inspire-theme-thesaurus-anchor-href" select="'https://www.eionet.europa.eu/gemet/nl/inspire-themes/'"/>
	<xsl:variable name="inspire-theme-thesaurus-anchor-value" select="'GEMET - INSPIRE thema''s, versie 1.0'"/>
	-->
	<!--aangepast door Gustaaf -->
	<!--DIT MOET HET ZIJN!!! -->
	<!--afgeckecked met Geraldine-->
	<xsl:variable name="inspire-theme-thesaurus" select="'GEMET - INSPIRE themes, version 1.0'"/>
	<xsl:variable name="inspire-theme-thesaurus-anchor-href" select="'http://inspire.ec.europa.eu/theme'"/>
	<xsl:variable name="inspire-theme-thesaurus-anchor-value" select="'GEMET - INSPIRE themes, version 1.0'"/>
	<!-- ============================================================================= -->
	<xsl:template match="*" mode="SrvDataIdentification">
		<xsl:param name="topic"/>
		<!--parameter nodig ???-->
		<xsl:param name="ows"/>
		<xsl:param name="wfs"/>
		<!--parameter nodig ???-->
		<xsl:variable name="s" select="Service|wfs:Service|wms:Service|ows:ServiceIdentification|ows11:ServiceIdentification|ows2:ServiceIdentification|wcs:Service"/>
		<!-- ============================================================================= -->
		<!-- === citation WCS OK-->
		<!-- ============================================================================= -->
		<citation>
			<CI_Citation>
				<title>
					<gco:CharacterString>
						<!--	<xsl:value-of select="$ows"/>-->
						<xsl:choose>
							<xsl:when test="$ows='true'">
								<xsl:value-of select="
                  ows11:ServiceIdentification/ows11:Title|
									ows:ServiceIdentification/ows:Title|							
									ows2:ServiceIdentification/ows2:Title|
									/wps1:Capabilities/ows11:ServiceIdentification/ows11:Title|
								    /wps2:Capabilities/ows2:ServiceIdentification/ows2:Title
								  "/>
							</xsl:when>
							<xsl:when test="name(.)='WFS_Capabilities'">
								<xsl:value-of select="wfs:Service/wfs:Title"/>
							</xsl:when>
							<xsl:when test="name(.)='WMS_Capabilities'">
								<xsl:value-of select="wms:Service/wms:Title"/>
							</xsl:when>
							<xsl:when test="name(.)='WMT_MS_Capabilities'">
								<xsl:value-of select="Service/Title"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="wcs:Service/wcs:title"/>
							</xsl:otherwise>
						</xsl:choose>
					</gco:CharacterString>
				</title>
				<!-- DateOfLastRevision -->
				<xsl:variable name="DateOfRevision">
					<xsl:if test="//*:ExtendedCapabilities/inspire_common:TemporalReference/inspire_common:DateOfLastRevision">
						<xsl:value-of select="//*:ExtendedCapabilities/inspire_common:TemporalReference/inspire_common:DateOfLastRevision"/>
					</xsl:if>
				</xsl:variable>
				<xsl:if test="string-length($DateOfRevision)>0">
					<date>
						<CI_Date>
							<date>
								<gco:Date>
									<xsl:value-of select="$DateOfRevision"/>
								</gco:Date>
							</date>
							<dateType>
								<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="revision"/>
							</dateType>
						</CI_Date>
					</date>
				</xsl:if>
				<!-- DateOfCreation -->
				<xsl:variable name="DateOfCreation">
					<xsl:if test="//*:ExtendedCapabilities/inspire_common:TemporalReference/inspire_common:DateOfCreation">
						<xsl:value-of select="//*:ExtendedCapabilities/inspire_common:TemporalReference/inspire_common:DateOfCreation"/>
					</xsl:if>
				</xsl:variable>
				<xsl:if test="string-length($DateOfCreation)>0">
					<date>
						<CI_Date>
							<date>
								<gco:Date>
									<xsl:value-of select="$DateOfCreation"/>
								</gco:Date>
							</date>
							<dateType>
								<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="creation"/>
							</dateType>
						</CI_Date>
					</date>
				</xsl:if>
				<!-- DateOfPublication -->
				<xsl:variable name="DateOfPublication">
					<xsl:if test="//*:ExtendedCapabilities/inspire_common:TemporalReference/inspire_common:DateOfPublication">
						<xsl:value-of select="//*:ExtendedCapabilities/inspire_common:TemporalReference/inspire_common:DateOfPublication"/>
					</xsl:if>
				</xsl:variable>
				<xsl:if test="string-length($DateOfPublication)>0">
					<date>
						<CI_Date>
							<date>
								<gco:Date>
									<xsl:value-of select="$DateOfPublication"/>
								</gco:Date>
							</date>
							<dateType>
								<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
							</dateType>
						</CI_Date>
					</date>
				</xsl:if>
				<!-- DateOfPublication in case of no DateOfPublication yet -->
				<xsl:if test="string-length($DateOfPublication)=0">
					<date>
						<CI_Date>
							<date>
								<gco:Date>
									<xsl:variable name="df">[Y0001]-[M01]-[D01]</xsl:variable>
									<xsl:value-of select="format-date(current-date(),$df)"/>
								</gco:Date>
							</date>
							<dateType>
								<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication"/>
							</dateType>
						</CI_Date>
					</date>
				</xsl:if>
			</CI_Citation>
		</citation>
		<!-- ============================================================================= -->
		<!-- === abstract WCS OK-->
		<!-- ============================================================================= -->
		<abstract>
			<gco:CharacterString>
				<xsl:choose>
					<xsl:when test="$ows='true'">
						<xsl:value-of select="normalize-space(ows:ServiceIdentification/ows:Abstract|
						ows2:ServiceIdentification/ows2:Abstract|
                      ows11:ServiceIdentification/ows11:Abstract|
                      /wps1:Capabilities/ows11:ServiceIdentification/ows11:Abstract|
                     /wps2:Capabilities/ows2:ServiceIdentification/ows2:Abstract)"/>
					</xsl:when>
					<xsl:when test="name(.)='WFS_Capabilities'">
						<xsl:value-of select="wfs:Service/wfs:Abstract"/>
					</xsl:when>
					<xsl:when test="name(.)='WMS_Capabilities'">
						<xsl:value-of select="wms:Service/wms:Abstract"/>
					</xsl:when>
					<xsl:when test="name(.)='WMT_MS_Capabilities'">
						<xsl:value-of select="Service/Abstract"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="wcs:Service/wcs:description"/>
					</xsl:otherwise>
				</xsl:choose>
			</gco:CharacterString>
		</abstract>
		<!-- ============================================================================= -->
		<!-- === pointOfContact WCS OK-->
		<!-- ============================================================================= -->
		<xsl:for-each select="//ContactInformation|//wcs:responsibleParty|//wms:responsibleParty|wms:Service/wms:ContactInformation|//ows:ServiceProvider|//ows11:ServiceProvider|//ows2:ServiceProvider">
			<pointOfContact>
				<CI_ResponsibleParty>
					<xsl:apply-templates select="." mode="RespPartyCustodian"/>
				</CI_ResponsibleParty>
			</pointOfContact>
		</xsl:for-each>
		<!-- ============================================================================= -->
		<!-- === descriptiveKeywords WCS OK-->
		<!-- ============================================================================= -->
		<descriptiveKeywords>
			<MD_Keywords>
				<keyword>
					<xsl:variable name="service" select="//inspire_common:MandatoryKeyword/inspire_common:KeywordValue"/>
					<xsl:choose>
						<xsl:when test="$service='infoMapAccessService'">
							<!--WMS/WMTS-->
							<gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoMapAccessService">
								Dienst kaarttoegang
							</gmx:Anchor>
						</xsl:when>
						<xsl:when test="$service='infoFeatureAccessService'">
							<!--WFS-->
							<gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoFeatureAccessService">
								Dienst objecttoegang
							</gmx:Anchor>
						</xsl:when>
						<xsl:when test="$service='infoCatalogueService'">
							<!--CSW-->
							<gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoCatalogueService">
								Catalogusdienst
							</gmx:Anchor>
						</xsl:when>
						<xsl:when test="$service='infoCoverageAccessService'">
							<!--WCS-->
							<gmx:Anchor xlink:href="http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceCategory/infoCoverageAccessService">
								Dienst rastergegevenstoegang
							</gmx:Anchor>
						</xsl:when>
					</xsl:choose>
				</keyword>
				<thesaurusName>
					<CI_Citation>
						<title>
							<gmx:Anchor xlink:href="{$inspire-service-taxonomy-thesaurus-anchor-href}">
								<xsl:value-of select="$inspire-service-taxonomy-thesaurus-anchor-value"/>
							</gmx:Anchor>
						</title>
						<date>
							<CI_Date>
								<date>
									<gco:Date>2008-12-03</gco:Date>
								</date>
								<dateType>
									<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</CI_DateTypeCode>
								</dateType>
							</CI_Date>
						</date>
					</CI_Citation>
				</thesaurusName>
			</MD_Keywords>
		</descriptiveKeywords>
		<!-- ============================================================================= -->
		<!-- === Service Type als Keyword met Anchor voor WFS|WMTS|WCS === -->
		<!-- ============================================================================= -->
		<xsl:choose>
			<xsl:when test="$ows='true'">
				<descriptiveKeywords>
					<MD_Keywords>
						<keyword>
							<gco:CharacterString>
								<xsl:value-of select="//ows:ServiceIdentification/ows:ServiceType|//ows11:ServiceIdentification/ows11:ServiceType|//ows2:ServiceIdentification/ows2:ServiceType"/>
							</gco:CharacterString>
						</keyword>
						<thesaurusName>
							<CI_Citation>
								<title>
									<gmx:Anchor xlink:href="{$gdi-vlaanderen-service-types-thesaurus-anchor-href}">
										<xsl:value-of select="$gdi-vlaanderen-service-types-thesaurus-anchor-value"/>
									</gmx:Anchor>
								</title>
								<date>
									<CI_Date>
										<date>
											<gco:Date>2015-03-16</gco:Date>
										</date>
										<dateType>
											<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</CI_DateTypeCode>
										</dateType>
									</CI_Date>
								</date>
							</CI_Citation>
						</thesaurusName>
					</MD_Keywords>
				</descriptiveKeywords>
			</xsl:when>
		</xsl:choose>
		<!-- ============================================================================= -->
		<!-- === aanroepen template Keywords === -->
		<!-- ============================================================================= -->
		<xsl:for-each select="$s/KeywordList|$s/wms:KeywordList|$s/wfs:keywords|$s/wcs:keywords|$s/ows:Keywords|$s/ows11:Keywords|$s/ows2:Keywords">
			<xsl:apply-templates select="." mode="Keywords"/>
		</xsl:for-each>
		<!-- ============================================================================= -->
		<!-- === MD_LegalConstraints WCS OK-->
		<!-- ============================================================================= -->
		<resourceConstraints>
			<MD_LegalConstraints>
				<useLimitation>
					<gco:CharacterString>Toegangs- en (her)gebruiksvoorwaarden</gco:CharacterString>
				</useLimitation>
				<useConstraints>
					<MD_RestrictionCode codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions"/>
				</useConstraints>
				<otherConstraints>
					<gmx:Anchor xlink:href="https://overheid.vlaanderen.be/Webdiensten-Gebruiksrecht">Gebruiksrecht geografische webdiensten (agentschap Informatie Vlaanderen)</gmx:Anchor>
				</otherConstraints>
			</MD_LegalConstraints>
		</resourceConstraints>
		<resourceConstraints>
			<MD_LegalConstraints>
				<useLimitation>
					<gco:CharacterString>Beperking(en) op de publieke toegang</gco:CharacterString>
				</useLimitation>
				<accessConstraints>
					<MD_RestrictionCode codeList="http://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_RestrictionCode" codeListValue="otherRestrictions"/>
				</accessConstraints>
				<otherConstraints>
					<gmx:Anchor xlink:href="https://inspire.ec.europa.eu/metadata-codelist/LimitationsOnPublicAccess/noLimitations">Geen beperkingen op de publieke toegang</gmx:Anchor>
				</otherConstraints>
			</MD_LegalConstraints>
		</resourceConstraints>
		<!-- ============================================================================= -->
		<!-- === srv:serviceType WCS OK-->
		<!-- ============================================================================= -->
		<!--

		servicetype in dutch

		<xsl:variable name="ServiceType" select="//*:ExtendedCapabilities/inspire_common:SpatialDataServiceType"/>

		<xsl:variable name="ServiceTypeUrl">
			<xsl:value-of select="concat('http://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceType/', $ServiceType)"/>
		</xsl:variable>
		
		<xsl:variable name="ServiceTypeName" select="document('https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceType/SpatialDataServiceType.nl.iso19135xml')//grg:RE_Register/grg:containedItem[@xlink:href=$ServiceTypeUrl]/grg:RE_RegisterItem/grg:name/gco:CharacterString"/>
		<srv:serviceType>
			<gco:LocalName codeSpace="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceType">
				<xsl:value-of select="$ServiceTypeName"/>
			</gco:LocalName>
		</srv:serviceType>-->
		<srv:serviceType>
			<gco:LocalName codeSpace="https://inspire.ec.europa.eu/metadata-codelist/SpatialDataServiceType">
				<xsl:value-of select="//*:ExtendedCapabilities/inspire_common:SpatialDataServiceType"/>
			</gco:LocalName>
		</srv:serviceType>
		<!-- ============================================================================= -->
		<!-- === extent WCS OK -->
		<!-- ============================================================================= -->
		<xsl:if test="name(.)!='wps:Capabilities'">
			<srv:extent>
				<EX_Extent>
					<geographicElement>
						<EX_GeographicBoundingBox>
							<xsl:choose>
								<xsl:when test="$ows='true' or name(.)='WCS_Capabilities'">
									<xsl:variable name="boxes">
										<xsl:choose>
											<xsl:when test="$ows='true'">
												<xsl:for-each select="//ows:WGS84BoundingBox/ows:LowerCorner|//ows11:WGS84BoundingBox/ows11:LowerCorner|//ows2:WGS84BoundingBox/ows2:LowerCorner">
													<xmin>
														<xsl:value-of select="substring-before(., ' ')"/>
													</xmin>
													<ymin>
														<xsl:value-of select="substring-after(., ' ')"/>
													</ymin>
												</xsl:for-each>
												<xsl:for-each select="//ows:WGS84BoundingBox/ows:UpperCorner|//ows11:WGS84BoundingBox/ows11:UpperCorner|//ows2:WGS84BoundingBox/ows2:UpperCorner">
													<xmax>
														<xsl:value-of select="substring-before(., ' ')"/>
													</xmax>
													<ymax>
														<xsl:value-of select="substring-after(., ' ')"/>
													</ymax>
												</xsl:for-each>
											</xsl:when>
											<xsl:when test="name(.)='WCS_Capabilities'">
												<xsl:for-each select="//wcs:lonLatEnvelope/gml:pos[1]">
													<xmin>
														<xsl:value-of select="substring-before(., ' ')"/>
													</xmin>
													<ymin>
														<xsl:value-of select="substring-after(., ' ')"/>
													</ymin>
												</xsl:for-each>
												<xsl:for-each select="//wcs:lonLatEnvelope/gml:pos[2]">
													<xmax>
														<xsl:value-of select="substring-before(., ' ')"/>
													</xmax>
													<ymax>
														<xsl:value-of select="substring-after(., ' ')"/>
													</ymax>
												</xsl:for-each>
											</xsl:when>
										</xsl:choose>
									</xsl:variable>
									<westBoundLongitude>
										<gco:Decimal>
											<xsl:value-of select="math:min(exslt:node-set($boxes)/*[name(.)='xmin'])"/>
										</gco:Decimal>
									</westBoundLongitude>
									<eastBoundLongitude>
										<gco:Decimal>
											<xsl:value-of select="math:max(exslt:node-set($boxes)/*[name(.)='xmax'])"/>
										</gco:Decimal>
									</eastBoundLongitude>
									<southBoundLatitude>
										<gco:Decimal>
											<xsl:value-of select="math:min(exslt:node-set($boxes)/*[name(.)='ymin'])"/>
										</gco:Decimal>
									</southBoundLatitude>
									<northBoundLatitude>
										<gco:Decimal>
											<xsl:value-of select="math:max(exslt:node-set($boxes)/*[name(.)='ymax'])"/>
										</gco:Decimal>
									</northBoundLatitude>
								</xsl:when>
								<xsl:otherwise>
									<westBoundLongitude>
										<gco:Decimal>
											<xsl:value-of select="math:min(//wms:EX_GeographicBoundingBox/wms:westBoundLongitude|//LatLonBoundingBox/@minx|//wfs:LatLongBoundingBox/@minx)"/>
										</gco:Decimal>
									</westBoundLongitude>
									<eastBoundLongitude>
										<gco:Decimal>
											<xsl:value-of select="math:max(//wms:EX_GeographicBoundingBox/wms:eastBoundLongitude|//LatLonBoundingBox/@maxx|//wfs:LatLongBoundingBox/@maxx)"/>
										</gco:Decimal>
									</eastBoundLongitude>
									<southBoundLatitude>
										<gco:Decimal>
											<xsl:value-of select="math:min(//wms:EX_GeographicBoundingBox/wms:southBoundLatitude|//LatLonBoundingBox/@miny|//wfs:LatLongBoundingBox/@miny)"/>
										</gco:Decimal>
									</southBoundLatitude>
									<northBoundLatitude>
										<gco:Decimal>
											<xsl:value-of select="math:max(//wms:EX_GeographicBoundingBox/wms:northBoundLatitude|//LatLonBoundingBox/@maxy|//wfs:LatLongBoundingBox/@maxy)"/>
										</gco:Decimal>
									</northBoundLatitude>
								</xsl:otherwise>
							</xsl:choose>
						</EX_GeographicBoundingBox>
					</geographicElement>
				</EX_Extent>
			</srv:extent>
		</xsl:if>
		<!-- ============================================================================= -->
		<!-- === couplingType WCS OK -->
		<!-- ============================================================================= -->
		<srv:couplingType>
			<srv:SV_CouplingType codeList="https://standards.iso.org/iso/19115/resources/Codelists/gml/SV_CouplingType.xml" codeListValue="tight"/>
		</srv:couplingType>
		<!-- ============================================================================= -->
		<!-- === containsOperations WCS OK -->
		<!-- ============================================================================= -->
		<xsl:for-each select="Capability/Request/*|
								wfs:Capability/wfs:Request/*|
								wms:Capability/wms:Request/*|
                                wcs:Capability/wcs:Request/*|
                                ows:OperationsMetadata/ows:Operation|
                                ows11:OperationsMetadata/ows11:Operation|
                                ows2:OperationsMetadata/ows2:Operation|
                                wps:ProcessOfferings/*|
                                wps1:ProcessOfferings/*|
                                wps2:Contents/*">
			<srv:containsOperations>
				<srv:SV_OperationMetadata>
					<srv:operationName>
						<gco:CharacterString>
							<xsl:choose>
								<xsl:when test="name(.)='wps:Process' or name(.)='wps:ProcessSummary'">
									WPS Process: <xsl:value-of select="ows:Title|ows11:Title|ows2:Title"/>
								</xsl:when>
								<xsl:when test="$ows='true'">
									<xsl:value-of select="@name"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="name(.)"/>
								</xsl:otherwise>
							</xsl:choose>
						</gco:CharacterString>
					</srv:operationName>
					<srv:DCP>
						<srv:DCPList codeList="https://standards.iso.org/iso/19115/resources/Codelists/gml/DCPList.xml" codeListValue="HTTP"/>
					</srv:DCP>
					<xsl:choose>
						<xsl:when test="$ows='true'">
							<xsl:for-each select="ows:DCP/ows:HTTP/ows:Get|
												ows11:DCP/ows11:HTTP/ows11:Get|
												ows2:DCP/ows2:HTTP/ows2:Get">
								<srv:connectPoint>
									<CI_OnlineResource>
										<linkage>
											<URL>
												<xsl:value-of select="@xlink:href"/>
											</URL>
										</linkage>
									</CI_OnlineResource>
								</srv:connectPoint>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<srv:connectPoint>
								<CI_OnlineResource>
									<linkage>
										<URL>
											<xsl:value-of select=".//Get/OnlineResource/@xlink:href|.//wms:Get/wms:OnlineResource/@xlink:href"/>
										</URL>
									</linkage>
								</CI_OnlineResource>
							</srv:connectPoint>
						</xsl:otherwise>
					</xsl:choose>
				</srv:SV_OperationMetadata>
			</srv:containsOperations>
		</xsl:for-each>
		<!-- ============================================================================= -->
		<!-- === operatesOn WCS OK-->
		<!-- ============================================================================= -->
		<!--WMS-->
		<xsl:for-each select="//wms:Layer/wms:MetadataURL/wms:OnlineResource/@xlink:href[not(.=preceding::wms:OnlineResource/@xlink:href)]">
			<xsl:choose>
				<xsl:when test="contains(.,'srv/dut/csw')">
					<srv:operatesOn xlink:href="{.}" uuidref="{../../../wms:Identifier}"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<!--WFS-->
		<xsl:for-each select="//wfs:FeatureTypeList/wfs:FeatureType/wfs:MetadataURL[not(.=preceding::wfs:MetadataURL)]">
			<xsl:choose>
				<xsl:when test="contains(.,'srv/dut/csw')">
					<srv:operatesOn xlink:href="{.}" uuidref="{//inspire_dls:SpatialDataSetIdentifier/inspire_common:Code}"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<!--WCS-->
		<xsl:for-each select="//wcs:Contents/wcs:CoverageSummary/ows2:Metadata/@xlink:href[not(.=preceding::ows2:Metadata/@xlink:href)]">
			<xsl:choose>
				<xsl:when test="contains(.,'srv/dut/csw')">
					<srv:operatesOn xlink:href="{.}" uuidref="{//inspire_dls:SpatialDataSetIdentifier/inspire_common:Code}"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<!--WMTS-->
		<xsl:for-each select="//wmts:Contents/wmts:Layer/ows11:Metadata/@xlink:href[not(.=preceding::ows11:Metadata/@xlink:href)]">
			<xsl:choose>
				<xsl:when test="contains(.,'srv/dut/csw')">
					<srv:operatesOn xlink:href="{.}" uuidref="{../../ows11:DatasetDescriptionSummary/ows11:Identifier}"/>
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<!-- ============================================================================= -->
	<!-- === template Keywords OK=== -->
	<!-- ============================================================================= -->
	<xsl:template match="*" mode="Keywords">
		<xsl:call-template name="get-vocabulary-keywords">
			<xsl:with-param name="thesaurusTitle" select="$gdi-vlaanderen-regios-thesaurus"/>
			<xsl:with-param name="thesaurusAnchor" select="$gdi-vlaanderen-regios-thesaurus-anchor-href"/>
			<xsl:with-param name="thesaurusAnchorValue" select="$gdi-vlaanderen-regios-thesaurus-anchor-value"/>
			<xsl:with-param name="thesaurusDate" select="'2013-04-18'"/>
		</xsl:call-template>
		<xsl:call-template name="get-vocabulary-keywords">
			<xsl:with-param name="thesaurusTitle" select="$gdi-vlaanderen-service-types-thesaurus"/>
			<xsl:with-param name="thesaurusAnchor" select="$gdi-vlaanderen-service-types-thesaurus-anchor-href"/>
			<xsl:with-param name="thesaurusAnchorValue" select="$gdi-vlaanderen-service-types-thesaurus-anchor-value"/>
			<xsl:with-param name="thesaurusDate" select="'2015-03-16'"/>
		</xsl:call-template>
		<xsl:call-template name="get-vocabulary-keywords">
			<xsl:with-param name="thesaurusTitle" select="$gdi-vlaanderen-trefwoorden-thesaurus"/>
			<xsl:with-param name="thesaurusAnchor" select="$gdi-vlaanderen-trefwoorden-thesaurus-anchor-href"/>
			<xsl:with-param name="thesaurusAnchorValue" select="$gdi-vlaanderen-trefwoorden-thesaurus-anchor-value"/>
			<xsl:with-param name="thesaurusDate" select="'2014-02-26'"/>
		</xsl:call-template>
		<xsl:call-template name="get-vocabulary-keywords">
			<xsl:with-param name="thesaurusTitle" select="$gemet-thesaurus"/>
			<xsl:with-param name="thesaurusAnchor" select="$gemet-thesaurus-anchor-href"/>
			<xsl:with-param name="thesaurusAnchorValue" select="$gemet-thesaurus-anchor-value"/>
			<xsl:with-param name="thesaurusDate" select="'2010-01-13'"/>
		</xsl:call-template>
		<xsl:call-template name="get-vocabulary-keywords">
			<xsl:with-param name="thesaurusTitle" select="$inspire-service-taxonomy-thesaurus"/>
			<xsl:with-param name="thesaurusAnchor" select="$inspire-service-taxonomy-thesaurus-anchor-href"/>
			<xsl:with-param name="thesaurusAnchorValue" select="$inspire-service-taxonomy-thesaurus-anchor-value"/>
			<xsl:with-param name="thesaurusDate" select="'2008-12-03'"/>
		</xsl:call-template>
		<xsl:call-template name="get-vocabulary-keywords">
			<xsl:with-param name="thesaurusTitle" select="$inspire-theme-thesaurus"/>
			<xsl:with-param name="thesaurusAnchor" select="$inspire-theme-thesaurus-anchor-href"/>
			<xsl:with-param name="thesaurusAnchorValue" select="$inspire-theme-thesaurus-anchor-value"/>
			<xsl:with-param name="thesaurusDate" select="'2008-06-01'"/>
		</xsl:call-template>
		<xsl:if test="count(Keyword[lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-regios-thesaurus) and 
									lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-service-types-thesaurus) and
									lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-trefwoorden-thesaurus) and 
									lower-case(@vocabulary)!=lower-case($gemet-thesaurus) and
									lower-case(@vocabulary)!=lower-case($inspire-service-taxonomy-thesaurus) and 
									lower-case(@vocabulary)!=lower-case($inspire-theme-thesaurus)]) + 
						count(wms:Keyword[lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-regios-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-service-types-thesaurus) and
										  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-trefwoorden-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($gemet-thesaurus) and
										  lower-case(@vocabulary)!=lower-case($inspire-service-taxonomy-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($inspire-theme-thesaurus)]) + 
						count(ows:Keyword[lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-regios-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-service-types-thesaurus) and
										  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-trefwoorden-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($gemet-thesaurus) and
									      lower-case(@vocabulary)!=lower-case($inspire-service-taxonomy-thesaurus) and 
									      lower-case(@vocabulary)!=lower-case($inspire-theme-thesaurus)]) + 
						count(ows11:Keyword[lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-regios-thesaurus) and 
											lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-service-types-thesaurus) and
											lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-trefwoorden-thesaurus) and 
											lower-case(@vocabulary)!=lower-case($gemet-thesaurus) and
											lower-case(@vocabulary)!=lower-case($inspire-service-taxonomy-thesaurus) and 
											lower-case(@vocabulary)!=lower-case($inspire-theme-thesaurus)]) + 
            count(ows2:Keyword[lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-regios-thesaurus) and 
											lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-service-types-thesaurus) and
											lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-trefwoorden-thesaurus) and 
											lower-case(@vocabulary)!=lower-case($gemet-thesaurus) and
											lower-case(@vocabulary)!=lower-case($inspire-service-taxonomy-thesaurus) and 
											lower-case(@vocabulary)!=lower-case($inspire-theme-thesaurus)]) + 
						count(wfs:Keyword[lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-regios-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-service-types-thesaurus) and
										  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-trefwoorden-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($gemet-thesaurus) and
										  lower-case(@vocabulary)!=lower-case($inspire-service-taxonomy-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($inspire-theme-thesaurus)]) + 
						count(wcs:keyword[lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-regios-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-service-types-thesaurus) and
										  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-trefwoorden-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($gemet-thesaurus) and
										  lower-case(@vocabulary)!=lower-case($inspire-service-taxonomy-thesaurus) and 
										  lower-case(@vocabulary)!=lower-case($inspire-theme-thesaurus)]) > 0">
			<!--Lijst M&R-->
			<xsl:for-each select="ows:Keyword | ows11:Keyword | ows2:Keyword | wfs:Keyword | wcs:keyword">
				<xsl:if test=".='Lijst M&amp;R INSPIRE'">
					<descriptiveKeywords>
						<MD_Keywords>
							<keyword>
								<!--	PETER :							<gmx:Anchor xlink:href="http://mir.geopunt.be/cl/Geopunt/GDI-Vlaanderen-Trefwoorden/LIJSTMRINSPIRE"><xsl:value-of select="."/></gmx:Anchor> -->
								<gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/LIJSTMRINSPIRE">
									<xsl:value-of select="."/>
								</gmx:Anchor>
							</keyword>
							<thesaurusName>
								<CI_Citation>
									<title>
										<gmx:Anchor xlink:href="{$gdi-vlaanderen-trefwoorden-thesaurus-anchor-href}">
											<xsl:value-of select="$gdi-vlaanderen-trefwoorden-thesaurus-anchor-value"/>
										</gmx:Anchor>
									</title>
									<date>
										<CI_Date>
											<date>
												<gco:Date>2014-02-26</gco:Date>
											</date>
											<dateType>
												<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</CI_DateTypeCode>
											</dateType>
										</CI_Date>
									</date>
								</CI_Citation>
							</thesaurusName>
						</MD_Keywords>
					</descriptiveKeywords>
				</xsl:if>
			</xsl:for-each>
			<!--other keywords-->
			<descriptiveKeywords>
				<MD_Keywords>
					<xsl:for-each select="Keyword | wms:Keyword | ows:Keyword | ows11:Keyword | ows2:Keyword | wfs:Keyword | wcs:keyword">
						<xsl:if test="lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-regios-thesaurus) and 
											  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-service-types-thesaurus) and
											  lower-case(@vocabulary)!=lower-case($gdi-vlaanderen-trefwoorden-thesaurus) and 
											  lower-case(@vocabulary)!=lower-case($gemet-thesaurus) and
											  lower-case(@vocabulary)!=lower-case($inspire-service-taxonomy-thesaurus) and 
											  lower-case(@vocabulary)!=lower-case($inspire-theme-thesaurus)">
							<xsl:variable name="keywordValue" select="normalize-space(.)"/>
							<xsl:if test="$keywordValue!='infoMapAccessService' and $keywordValue!='infoFeatureAccessService' and $keywordValue!='Lijst M&amp;R INSPIRE' and  $keywordValue!='infoCoverageAccessService'">
								<keyword>
									<gco:CharacterString>
										<xsl:value-of select="."/>
									</gco:CharacterString>
								</keyword>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
				</MD_Keywords>
			</descriptiveKeywords>
		</xsl:if>
	</xsl:template>
	<!-- ============================================================================= -->
	<!-- === template get-vocabulary-keywords OK === -->
	<!-- ============================================================================= -->
	<xsl:template name="get-vocabulary-keywords">
		<xsl:param name="thesaurusTitle"/>
		<xsl:param name="thesaurusDate"/>
		<xsl:param name="thesaurusAnchor"/>
		<xsl:param name="thesaurusAnchorValue"/>
		<xsl:param name="KeywordAnchor"/>
		<xsl:variable name="lowerCaseThesaurusTitle" select="lower-case($thesaurusTitle)"/>
		<!--inspireTheme_dut-->
		<xsl:if test="(count(//inspire_common:Keyword[ends-with(@xsi:type,'inspireTheme_dut')]/inspire_common:KeywordValue) > 0 and 
		$lowerCaseThesaurusTitle=lower-case($inspire-theme-thesaurus)) or 
		(count(Keyword[lower-case(@vocabulary)=$lowerCaseThesaurusTitle]) + count(wms:Keyword[lower-case(@vocabulary)=$lowerCaseThesaurusTitle]) + count(ows:Keyword[lower-case(@vocabulary)=$lowerCaseThesaurusTitle]) + count(ows11:Keyword[lower-case(@vocabulary)=$lowerCaseThesaurusTitle]) + count(ows2:Keyword[lower-case(@vocabulary)=$lowerCaseThesaurusTitle]) + count(wfs:Keywords[lower-case(@vocabulary)=$lowerCaseThesaurusTitle]) + count(wcs:keyword[lower-case(@vocabulary)=$lowerCaseThesaurusTitle]) > 0)">
			<descriptiveKeywords>
				<MD_Keywords>
					<xsl:for-each select="Keyword | wms:Keyword | ows:Keyword | ows11:Keyword | ows2:Keyword | wfs:Keyword | wcs:keyword">
						<xsl:if test="lower-case(@vocabulary)=$lowerCaseThesaurusTitle">
							<xsl:variable name="keywordValue" select="normalize-space(.)"/>
							<xsl:if test="$keywordValue!='infoMapAccessService' and $keywordValue!='infoFeatureAccessService'">
								<xsl:choose>
									<xsl:when test="$keywordValue='Lijst M&amp;R INSPIRE'">
										<keyword>
											<!--PETER: old value					<gmx:Anchor xlink:href="http://mir.geopunt.be/cl/Geopunt/GDI-Vlaanderen-Trefwoorden/LIJSTMRINSPIRE"><xsl:value-of select="."/></gmx:Anchor> -->
											<gmx:Anchor xlink:href="https://metadata.vlaanderen.be/id/GDI-Vlaanderen-Trefwoorden/LIJSTMRINSPIRE">
												<xsl:value-of select="."/>
											</gmx:Anchor>
										</keyword>
									</xsl:when>
									<xsl:otherwise>
										<keyword>
											<gco:CharacterString>
												<xsl:value-of select="$keywordValue"/>
											</gco:CharacterString>
										</keyword>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
					<xsl:if test="$lowerCaseThesaurusTitle=lower-case($inspire-theme-thesaurus)">
						<xsl:variable name="inspire-theme-thesaurus-keywords-1">
							<xsl:value-of select="concat('[',string-join(Keyword[lower-case(@vocabulary)=$lowerCaseThesaurusTitle],'],['),']')"/>
						</xsl:variable>
						<xsl:variable name="inspire-theme-thesaurus-keywords-2">
							<xsl:value-of select="concat('[',string-join(*:Keyword[lower-case(@vocabulary)=$lowerCaseThesaurusTitle],'],['),']')"/>
						</xsl:variable>
						<xsl:variable name="inspire-theme-thesaurus-keywords-3">
							<xsl:value-of select="concat('[',string-join(wcs:keyword[lower-case(@vocabulary)=$lowerCaseThesaurusTitle],'],['),']')"/>
						</xsl:variable>
						<xsl:variable name="inspire-theme-thesaurus-keywords">
							<xsl:value-of select="concat($inspire-theme-thesaurus-keywords-1,',',$inspire-theme-thesaurus-keywords-2,',',$inspire-theme-thesaurus-keywords-3)"/>
						</xsl:variable>
						<xsl:for-each select="//inspire_common:Keyword[ends-with(@xsi:type,'inspireTheme_dut')]/inspire_common:KeywordValue">
							<xsl:variable name="keywordValue" select="normalize-space(.)"/>
							<xsl:if test="$keywordValue!='infoMapAccessService' and $keywordValue!='infoFeatureAccessService' and $keywordValue!='infoCoverageAccessService' 
							and not(contains($inspire-theme-thesaurus-keywords,concat('[',$keywordValue,']')))">
								<xsl:variable name="inspireTheme" select="document('https://inspire.ec.europa.eu/theme/theme.nl.xml')//theme:register/theme:containeditems/theme:theme[theme:label=$keywordValue]/@id"/>
								<keyword>
									<gmx:Anchor xlink:href="{$inspireTheme}">
										<xsl:value-of select="$keywordValue"/>
									</gmx:Anchor>
								</keyword>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>
					<thesaurusName>
						<CI_Citation>
							<title>
								<gmx:Anchor xlink:href="{$thesaurusAnchor}">
									<xsl:value-of select="$thesaurusAnchorValue"/>
								</gmx:Anchor>
							</title>
							<date>
								<CI_Date>
									<date>
										<gco:Date>
											<xsl:value-of select="$thesaurusDate"/>
										</gco:Date>
									</date>
									<dateType>
										<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</CI_DateTypeCode>
									</dateType>
								</CI_Date>
							</date>
						</CI_Citation>
					</thesaurusName>
				</MD_Keywords>
			</descriptiveKeywords>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
