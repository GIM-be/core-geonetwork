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
<!--
Mapping between:
- WMS 1.0.0
- WMS 1.1.1
- WMS 1.3.0
- WCS 1.0.0
- WFS 1.0.0
- WFS 1.1.0
- WPS 0.4.0
- WPS 1.0.0
- WPS 2.0.0
... to ISO19119.
 -->
 <!--	xmlns:wcs="http://www.opengis.net/wcs" -->
<xsl:stylesheet 
	xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:srv="http://www.isotc211.org/2005/srv" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	xmlns:wfs="http://www.opengis.net/wfs" 

	xmlns:wcs="http://www.opengis.net/wcs"
	xmlns:wcs2="http://www.opengis.net/wcs/2.0"
	
	xmlns:wms="http://www.opengis.net/wms" 
	xmlns:wmts="http://www.opengis.net/wmts/1.0" 
	xmlns:ows="http://www.opengis.net/ows" 
	xmlns:owsg="http://www.opengeospatial.net/ows" 
	xmlns:ows11="http://www.opengis.net/ows/1.1" 
	xmlns:ows2="http://www.opengis.net/ows/2.0" 
	xmlns:wps="http://www.opengeospatial.net/wps" 
	xmlns:wps1="http://www.opengis.net/wps/1.0.0" 
	xmlns:wps2="http://www.opengis.net/wps/2.0" 
	xmlns:inspire_common="http://inspire.ec.europa.eu/schemas/common/1.0" 
	xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0" 
	xmlns:inspire_vs="http://inspire.ec.europa.eu/schemas/inspire_vs/1.0" 
	xmlns:gmx="http://www.isotc211.org/2005/gmx" 
	xmlns:gml="http://www.opengis.net/gml/3.2" version="2.0" xmlns="http://www.isotc211.org/2005/gmd" 
	extension-element-prefixes="wcs wcs2 ows wfs ows11 wps wps1 wps2 owsg inspire_common inspire_vs"
        exclude-result-prefixes="#all">

	<!-- ============================================================================= -->
	<xsl:param name="uuid">uuid</xsl:param>
	<xsl:param name="lang">dut</xsl:param>
	<xsl:param name="topic"/> <!--parameter nodig ???-->
	<!-- ============================================================================= -->
	<xsl:include href="resp-party.xsl"/>
	<xsl:include href="ref-system.xsl"/>
	<xsl:include href="identification.xsl"/>
	<!-- ============================================================================= -->
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:variable name="isUsing2005Schema" select="true()"/>
	<xsl:variable name="isUsing2007Schema" select="false()"/>
	<!-- ============================================================================= -->
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- ============================================================================= -->
	<xsl:template match="WMT_MS_Capabilities|wfs:WFS_Capabilities
		
		|wcs:WCS_Capabilities|wcs2:Capabilities|wcs:Capabilities|wcs2:WCS_Capabilities|
         
         wps:Capabilities|wps1:Capabilities|wps2:Capabilities|wms:WMS_Capabilities|wmts:Capabilities">
		<xsl:variable name="ows">
			<xsl:choose>

				<xsl:when test="(local-name(.)='WFS_Capabilities' and (namespace-uri(.)='http://www.opengis.net/wfs' 
				  or namespace-uri(.)='http://www.opengis.net/wfs/2.0') and (@version='1.1.0' or @version='2.0.0'))
				  or (local-name(.)='WCS_Capabilities' and namespace-uri(.)='http://www.opengis.net/wcs') 
				  or (local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengis.net/wcs/2.0') 
				  or (local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengis.net/ows/2.0') 
				  or (local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengis.net/wmts/1.0') 
				  or (local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengeospatial.net/wps')
				  or (local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengis.net/wps/1.0.0')
				  or (local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengis.net/wps/2.0')">true</xsl:when>
				<xsl:otherwise>false</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="wfs"> <!-- variabele wordt niet gebruikt! -->
			<xsl:choose>
				<xsl:when
					test="local-name(.)='WFS_Capabilities' and (namespace-uri(.)='http://www.opengis.net/wfs' 
					or namespace-uri(.)='http://www.opengis.net/ows') and @version='1.1.0'"><xsl:value-of select="true()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="false()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		
		<MD_Metadata>
		
                        <xsl:call-template name="add-namespaces"/>
                        <xsl:choose>
                            <xsl:when test="$isUsing2005Schema">
                                <xsl:attribute name="xsi:schemaLocation"
                                       select="'http://www.isotc211.org/2005/gmx http://schemas.opengis.net/iso/19139/20060504/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd'"/>
                            </xsl:when>
                            <xsl:when test="$isUsing2007Schema">
                                <xsl:attribute name="xsi:schemaLocation"
                                       select="'http://www.isotc211.org/2005/gmx http://schemas.opengis.net/iso/19139/20070417/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20070417/srv/1.0/srv.xsd http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20070417/gmd/gmd.xsd'"/>
                            </xsl:when>
                        </xsl:choose>

			<!-- ============================================================================= -->
			<!-- === fileIdentifier OK-->
			<!-- ============================================================================= -->	
			<xsl:variable name="inspireMetadataUrl">
				<xsl:value-of select="//inspire_common:MetadataUrl/inspire_common:URL"/>
			</xsl:variable>
			<xsl:variable name="leftPart" select="substring-before(upper-case($inspireMetadataUrl),'ID=')"/>
			<xsl:variable name="rightPart" select="substring($inspireMetadataUrl,string-length($leftPart)+1)"/>
			<xsl:variable name="idPart">
				<xsl:if test="contains($rightPart,'&amp;')">
					<xsl:value-of select="substring(substring-before($rightPart,'&amp;'),4)"/>
				</xsl:if>
				<xsl:if test="not(contains($rightPart,'&amp;'))">
					<xsl:value-of select="substring($rightPart,4)"/>
				</xsl:if>
			</xsl:variable>

			<fileIdentifier>
				<gco:CharacterString>
					<xsl:if test="string-length($idPart)>0">
						<xsl:value-of select="$idPart"/>
					</xsl:if>
					<xsl:if test="not(string-length($idPart)>0)">
						<xsl:value-of select="$uuid"/>
					</xsl:if>
				</gco:CharacterString>
			</fileIdentifier>

			<!-- ============================================================================= -->
			<!-- === language OK-->
			<!-- ============================================================================= -->	
			<language>
				<!--<gco:CharacterString>JUST TO TEST</gco:CharacterString>-->
				<LanguageCode codeList="https://www.loc.gov/standards/iso639-2" codeListValue="{$lang}">Nederlands</LanguageCode>
			</language>

			<!-- ============================================================================= -->
			<!-- === characterSet OK-->
			<!-- ============================================================================= -->	
			<characterSet>
				<MD_CharacterSetCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8">UTF-8</MD_CharacterSetCode>
			</characterSet>

			<!-- ============================================================================= -->
			<!-- === hierarchyLevel and hierarchyLevelName OK-->
			<!-- ============================================================================= -->	
			<hierarchyLevel>
				<MD_ScopeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_ScopeCode" codeListValue="service"/>
			</hierarchyLevel>
			<hierarchyLevelName>
				<gco:CharacterString>Dienst</gco:CharacterString>
			</hierarchyLevelName>

			<!-- ============================================================================= -->
			<!-- === contact OK-->
			<!-- ============================================================================= -->	
			<xsl:choose>
				<xsl:when test="Service/ContactInformation| wfs:Service/wfs:ContactInformation|
								wms:Service/wms:ContactInformation|
								ows:ServiceProvider|
								owsg:ServiceProvider|
								ows11:ServiceProvider|
								ows2:ServiceProvider">
								<xsl:for-each select="Service/ContactInformation|
										wfs:Service/wfs:ContactInformation|
										wms:Service/wms:ContactInformation|
										ows:ServiceProvider|
										owsg:ServiceProvider|
										ows11:ServiceProvider|
										ows2:ServiceProvider">
						<contact>
							<CI_ResponsibleParty>
								<xsl:apply-templates select="." mode="RespParty"/>
							</CI_ResponsibleParty>
						</contact>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<contact gco:nilReason="missing"/>
				</xsl:otherwise>
			</xsl:choose>

			<!-- ============================================================================= -->
			<!-- === dateStamp OK-->
			<!-- ============================================================================= -->	
			<xsl:variable name="df">[Y0001]-[M01]-[D01]</xsl:variable>
			<dateStamp>
				<gco:Date>
					<xsl:value-of select="format-date(current-date(),$df)"/>
				</gco:Date>
			</dateStamp>
			
			<!-- ============================================================================= -->
			<!-- === metadataStandardName and metadataStandardVersion OK-->
			<!-- ============================================================================= -->	
			<metadataStandardName>
				<gco:CharacterString>ISO 19119:2005/Amd 1:2008/INSPIRE-TG2.0</gco:CharacterString>
			</metadataStandardName>
			<metadataStandardVersion>
				<gco:CharacterString>GDI-Vlaanderen Best Practices - versie 2.0</gco:CharacterString>
			</metadataStandardVersion>
			
			<!-- ============================================================================= -->
			<!-- === referenceSystemInfo OK-->
			<!-- ============================================================================= -->	
			<!-- 
			WMS-raadpleegdiensten (geoservices en inspire): Op hoofd-layer-niveau zijn de verschillende CRS'en gedefinieerd
			WMTS: 3 TileMatrixSets zijn gedefinieerd met telkens een SupportedCRS
			WFS-overdrachtdiensten (geoservices): Per FeatureType is een DefaultSRS en meerdere OtherSRS'en gedefinieerd in de vorm van urn:ogc:def:crs:EPSG:31370
			WFS-overdrachtdiensten (inspire): Per FeatureType is een DefaultSRS en meerdere OtherSRS'en gedefinieerd in de vorm van een URL

			CRS:84 en EPSG:102100 hebben een specifieke URL
			URL-definities kunnen zo gebruikt worden
			Anders wordt ref-system.xsl aangeroepen-->
			<xsl:for-each select="wms:Capability/wms:Layer/wms:CRS|wfs:FeatureTypeList/wfs:FeatureType/wfs:DefaultSRS[not(.=preceding::wfs:DefaultSRS)]|wfs:FeatureTypeList/wfs:FeatureType/wfs:OtherSRS[not(.=preceding::wfs:OtherSRS)]|wmts:Contents/wmts:TileMatrixSet/ows11:SupportedCRS">
				<referenceSystemInfo>
					<MD_ReferenceSystem>
						<xsl:choose>
							<xsl:when test="contains(.,'CRS:84')">
								<referenceSystemIdentifier>
									<RS_Identifier>
										<code>
											<gmx:Anchor xlink:href="http://www.opengis.net/def/crs/OGC/1.3/CRS84">WGS 84 longitude-latitude</gmx:Anchor>
										</code>
									</RS_Identifier>
								</referenceSystemIdentifier>
							</xsl:when>
							<xsl:when test="contains(.,'102100')">
								<referenceSystemIdentifier>
									<RS_Identifier>
										<code>
											<gmx:Anchor xlink:href="http://www.opengis.net/def/crs/EPSG/0/102100">Spherical Mercator (unofficial deprecated ESRI)</gmx:Anchor>
										</code>
									</RS_Identifier>
								</referenceSystemIdentifier>
							</xsl:when>
							<xsl:when test="contains(.,'www.opengis.net')">
								<referenceSystemIdentifier>
									<RS_Identifier>
										<code>
											<gmx:Anchor xlink:href="{.}">
												<xsl:value-of select="document(.)//gml:name"/>
											</gmx:Anchor>
										</code>
									</RS_Identifier>
								</referenceSystemIdentifier>
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="." mode="RefSystemTypes"/>
							</xsl:otherwise>
						</xsl:choose>
					</MD_ReferenceSystem>
				</referenceSystemInfo>
			</xsl:for-each>

			<!-- ============================================================================= -->
			<!-- === identificationInfo NOK-->
			<!-- ============================================================================= -->				
			<identificationInfo>
				<srv:SV_ServiceIdentification>
					<xsl:apply-templates select="." mode="SrvDataIdentification">
						<xsl:with-param name="topic"><xsl:value-of select="$topic"/></xsl:with-param> <!--parameter nodig ???-->
						<xsl:with-param name="ows"><xsl:value-of select="$ows"/></xsl:with-param>
						<xsl:with-param name="wfs"><xsl:value-of select="$wfs" /></xsl:with-param> <!--parameter nodig ???-->
					</xsl:apply-templates>
				</srv:SV_ServiceIdentification>
			</identificationInfo>

			<!-- ============================================================================= -->
			<!-- === distributionInfo OK-->
			<!-- ============================================================================= -->					
			<distributionInfo>
				<MD_Distribution>
					<transferOptions>
						<MD_DigitalTransferOptions>
							<onLine>
								<CI_OnlineResource>
									<linkage>
										<URL>
											<xsl:choose>
												<!--WFS of WMTS-->
												<xsl:when test="$ows='true'">
													<xsl:variable name="ows_capabilities">
														<xsl:value-of select="//ows:Operation[@name='GetCapabilities']/ows:DCP/ows:HTTP/ows:Get/@xlink:href|
                                                  //ows11:Operation[@name='GetCapabilities']/ows11:DCP/ows11:HTTP/ows11:Get/@xlink:href|
                                                //ows2:Operation[@name='GetCapabilities']/ows2:DCP/ows2:HTTP/ows2:Get/@xlink:href"/>
													</xsl:variable>
													<xsl:choose>
														<xsl:when test="local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengis.net/wmts/1.0'"><!--WMTS-->
															<xsl:value-of select="concat(normalize-space($ows_capabilities),'service=WMTS&amp;version=1.0.0&amp;request=getcapabilities')"/>
														</xsl:when>
														<xsl:otherwise><!--WFS-->
															<xsl:choose>
																<xsl:when test="ends-with($ows_capabilities,'?')">
																	<xsl:value-of select="concat(normalize-space($ows_capabilities),'service=WFS&amp;request=getcapabilities')"/>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:value-of select="concat(normalize-space($ows_capabilities),'?service=WFS&amp;request=getcapabilities')"/>
																</xsl:otherwise>
															</xsl:choose>
														</xsl:otherwise>
													</xsl:choose>                                                
												</xsl:when>
												<!--WMS-->
												<xsl:when test="name(.)='WMS_Capabilities'">
													<xsl:variable name="capabilities">													
														<xsl:value-of select="//wms:GetCapabilities/wms:DCPType/wms:HTTP/wms:Get/wms:OnlineResource/@xlink:href"/>
													</xsl:variable>
													<xsl:choose>
														<xsl:when test="ends-with($capabilities,'?')">
															<xsl:value-of select="concat(normalize-space($capabilities),'service=WMS&amp;request=getcapabilities')"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="concat(normalize-space($capabilities),'?service=WMS&amp;request=getcapabilities')"/>
														</xsl:otherwise>
													</xsl:choose>
												</xsl:when>
												<xsl:when test="name(.)='WFS_Capabilities'">
													<xsl:value-of select="//wfs:GetCapabilities/wfs:DCPType/wfs:HTTP/wfs:Get/@onlineResource"/>
												</xsl:when>
												<xsl:when test="name(.)='WMT_MS_Capabilities'">
													<xsl:value-of select="//GetCapabilities/DCPType/HTTP/Get/OnlineResource[1]/@xlink:href"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="//wcs:GetCapabilities//wcs:OnlineResource[1]/@xlink:href"/>
												</xsl:otherwise>
											</xsl:choose>
										</URL>
									</linkage>
									<protocol>
										<xsl:variable name="protocol">
											<xsl:choose>
												<!--WFS of WMTS-->
												<xsl:when test="$ows='true'">
													<xsl:choose>
														<xsl:when test="local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengis.net/wmts/1.0'">WMTS</xsl:when><!--WMTS-->
														<xsl:otherwise>WFS</xsl:otherwise><!--WFS-->
													</xsl:choose>
												</xsl:when>
												<!--WMS-->
												<xsl:when test="name(.)='WMS_Capabilities'">WMS</xsl:when>
											</xsl:choose>
										</xsl:variable>
										<xsl:variable name="protocolStandaard">
											<xsl:value-of select="concat('http://www.opengeospatial.org/standards/', lower-case($protocol))"/>
										</xsl:variable>
										<gmx:Anchor xlink:href="{$protocolStandaard}">OGC:<xsl:value-of select="$protocol"/></gmx:Anchor>
									</protocol>
									<name>
										<xsl:variable name="ServiceTitel">
											<xsl:choose>
												<!--WFS | WMTS-->
												<xsl:when test="$ows='true'">
													<xsl:value-of select="ows:ServiceIdentification/ows:Title|
													  ows11:ServiceIdentification/ows11:Title|
													  /wps1:Capabilities/ows11:ServiceIdentification/ows11:Title|
													  /wps2:Capabilities/ows2:ServiceIdentification/ows2:Title"/>
												</xsl:when>
												<!--WMS-->
												<xsl:when test="name(.)='WMS_Capabilities'">
													<xsl:value-of select="wms:Service/wms:Title"/>
												</xsl:when>
											</xsl:choose>
										</xsl:variable>
										<gco:CharacterString>Capabilities van de webdienst <xsl:value-of select="$ServiceTitel"/></gco:CharacterString>
									</name>
									<description>
										<gmx:Anchor xlink:href="https://inspire.ec.europa.eu/metadata-codelist/OnLineDescriptionCode/accessPoint">access point</gmx:Anchor>
									</description>
									<function>
										<CI_OnLineFunctionCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_OnLineFunctionCode" codeListValue="information"/>
									</function>
								</CI_OnlineResource>
							</onLine>
						</MD_DigitalTransferOptions>
					</transferOptions>
				</MD_Distribution>
			</distributionInfo>

			<!-- ============================================================================= -->
			<!-- === dataQualityInfo OK-->
			<!-- ============================================================================= -->				
			<dataQualityInfo>
				<DQ_DataQuality>
					<scope>
						<DQ_Scope>
							<level>
								<MD_ScopeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#MD_ScopeCode" codeListValue="service"/>
							</level>
							<levelDescription>
								<MD_ScopeDescription>
									<other>
										<gco:CharacterString>Dienst</gco:CharacterString>
									</other>
								</MD_ScopeDescription>
							</levelDescription>
						</DQ_Scope>
					</scope>
					
					<xsl:variable name="inspireCommonUri">
						<xsl:value-of select="//inspire_common:Conformity/inspire_common:Specification/inspire_common:URI"/>
					</xsl:variable>
					<xsl:variable name="inspireCommonConformanceDegree">
						<xsl:value-of select="//inspire_common:Conformity/inspire_common:Degree"/>
					</xsl:variable>					
					
					<xsl:if test="starts-with($inspireCommonUri,'OJ:L:2010:323:0011:0102:')">
						<report>
							<DQ_DomainConsistency>
								<result>
									<DQ_ConformanceResult>
										<specification>
											<CI_Citation>
												<title>
													<gmx:Anchor xlink:href="https://eur-lex.europa.eu/legal-content/NL/TXT/?uri=CELEX:02010R1089-20141231">VERORDENING (EU) Nr. 1089/2010 VAN DE COMMISSIE van 23 november 2010 ter uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad betreffende de interoperabiliteit van verzamelingen ruimtelijke gegevens en van diensten met betrekking tot ruimtelijke gegevens</gmx:Anchor>
												</title>
												<date>
													<CI_Date>
														<date>
															<gco:Date>2010-12-08</gco:Date>
														</date>
														<dateType>
															<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</CI_DateTypeCode>
														</dateType>
													</CI_Date>
												</date>
											</CI_Citation>
										</specification>
										<explanation>
											<gco:CharacterString>Geharmoniseerd volgens INSPIRE verordening</gco:CharacterString>
										</explanation>
										<xsl:choose>
											<xsl:when test="inspire_common:Degree='conformant'">
												<pass>
													<gco:Boolean>true</gco:Boolean>
												</pass>
											</xsl:when>
											<xsl:otherwise>
												<pass>
													<gco:Boolean>false</gco:Boolean>
												</pass>
											</xsl:otherwise>
										</xsl:choose>
									</DQ_ConformanceResult>
								</result>
							</DQ_DomainConsistency>
						</report>
					</xsl:if>
					
					<report>
						<DQ_DomainConsistency>
							<result>
								<DQ_ConformanceResult>
									<specification>
										<CI_Citation>
											<title>
												<gmx:Anchor xlink:href="https://eur-lex.europa.eu/eli/reg/2009/976">Verordening (EG) n r. 976/2009 van de Commissie van 19 oktober 2009 tot uitvoering van Richtlijn 2007/2/EG van het Europees Parlement en de Raad wat betreft de netwerkdiensten</gmx:Anchor>
											</title>
											<date>
												<CI_Date>
													<date>
														<gco:Date>2009-10-19</gco:Date>
													</date>
													<dateType>
														<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</CI_DateTypeCode>
													</dateType>
												</CI_Date>
											</date>
										</CI_Citation>
									</specification>
									<explanation>
										<gco:CharacterString>Geharmoniseerd volgens INSPIRE verordening</gco:CharacterString>
									</explanation>
									<pass>
										<gco:Boolean>true</gco:Boolean>
									</pass>
								</DQ_ConformanceResult>
							</result>
						</DQ_DomainConsistency>
					</report>					
					
					<xsl:variable name="NetwerkDienst">
						<xsl:choose>
							<!--WFS of WMTS-->
							<xsl:when test="$ows='true'">
								<xsl:choose>
									<!--WMTS-->
									<xsl:when test="local-name(.)='Capabilities' and namespace-uri(.)='http://www.opengis.net/wmts/1.0'">View</xsl:when>
									<!--WFS-->
									<xsl:otherwise>Download</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<!--WMS-->
							<xsl:when test="name(.)='WMS_Capabilities'">View</xsl:when>
						</xsl:choose>
					</xsl:variable>
					
					<report>
						<DQ_DomainConsistency>
							<result>
								<DQ_ConformanceResult>
									<specification>
										<CI_Citation>
											<title>
												<xsl:choose>
													<xsl:when test="$NetwerkDienst='View'">
														<gmx:Anchor xlink:href="https://inspire.ec.europa.eu/documents/technical-guidance-implementation-inspire-view-services-1">Technical Guidance for the implementation of INSPIRE View Services</gmx:Anchor>
													</xsl:when>
													<xsl:otherwise>
														<gmx:Anchor xlink:href="https://inspire.ec.europa.eu/documents/technical-guidance-implementation-inspire-download-services">Technical Guidance for the implementation of INSPIRE Download Services</gmx:Anchor>
													</xsl:otherwise>
												</xsl:choose>
											</title>
											<date>
												<CI_Date>
													<date>
														<xsl:choose>
															<xsl:when test="$NetwerkDienst='View'">
																<gco:Date>2013-04-04</gco:Date>
															</xsl:when>
															<xsl:otherwise>
																<gco:Date>2013-08-09</gco:Date>
															</xsl:otherwise>
														</xsl:choose>
													</date>
													<dateType>
														<CI_DateTypeCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_DateTypeCode" codeListValue="publication">publication</CI_DateTypeCode>
													</dateType>
												</CI_Date>
											</date>
										</CI_Citation>
									</specification>
									<explanation>
										<gco:CharacterString>Geharmoniseerd volgens INSPIRE richtlijn</gco:CharacterString>
									</explanation>
									<pass>
										<gco:Boolean>true</gco:Boolean>
									</pass>
								</DQ_ConformanceResult>
							</result>
						</DQ_DomainConsistency>
					</report>
				</DQ_DataQuality>
			</dataQualityInfo>
		</MD_Metadata>
	</xsl:template>
        <xsl:template name="add-namespaces">
            <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
            <xsl:namespace name="gco" select="'http://www.isotc211.org/2005/gco'"/>
            <xsl:namespace name="gmd" select="'http://www.isotc211.org/2005/gmd'"/>
            <xsl:namespace name="gmx" select="'http://www.isotc211.org/2005/gmx'"/>
            <xsl:namespace name="gts" select="'http://www.isotc211.org/2005/gts'"/>
            <xsl:namespace name="gsr" select="'http://www.isotc211.org/2005/gsr'"/>
            <xsl:namespace name="gmi" select="'http://www.isotc211.org/2005/gmi'"/>
            <xsl:namespace name="srv" select="'http://www.isotc211.org/2005/srv'"/>
            <xsl:choose>
                <xsl:when test="$isUsing2005Schema and not($isUsing2007Schema)">
                    <xsl:namespace name="gml" select="'http://www.opengis.net/gml'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:namespace name="gml" select="'http://www.opengis.net/gml/3.2'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:namespace name="xlink" select="'http://www.w3.org/1999/xlink'"/>
        </xsl:template>
</xsl:stylesheet>
