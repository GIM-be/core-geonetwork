<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:gmx="http://www.isotc211.org/2005/gmx">

	<xsl:output method="xml" indent="yes"/>

	<!-- Change elements-->
	<xsl:template match="gmd:referenceSystemIdentifier/*[name()=('gmd:RS_Identifier','gmd:MD_Identifier')]" priority="1000">
		<xsl:call-template name="logAttributesAndValue">
			<xsl:with-param name="element" select="gmd:code/gco:CharacterString"/>
		</xsl:call-template>
		<xsl:variable name="codeElement">
			<xsl:call-template name="getCodeAsAnchor">
				<xsl:with-param name="code" select="gmd:code/gco:CharacterString"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$codeElement=''">
			<xsl:copy copy-namespaces="no">
				<xsl:apply-templates select="@*|node()"/>
			</xsl:copy>
		</xsl:if>
		<xsl:if test="not ($codeElement='')">
			<xsl:variable name="xlinkHref" select="$codeElement/gmd:code/gmx:Anchor/@xlink:href" />
			<xsl:message><xsl:value-of select="concat($logPrefix,'Updating element ', name(.), ' with ', if ($xlinkHref) then concat(' Anchor xlink:href ', $xlinkHref, ' and value ') else '', $codeElement/*/.)"/></xsl:message>
			<xsl:copy copy-namespaces="no">
				<xsl:copy-of select="$codeElement"/>
			</xsl:copy>
		</xsl:if>
	</xsl:template>

	<!-- Change elements-->
	<xsl:template name="getCodeAsAnchor">
		<xsl:param name="code"/>
		<xsl:choose>
			<xsl:when test="$code=('31370','EPSG:31370')"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/31370">Belge 1972 / Belgian Lambert 72</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code=('http://www.opengis.net/def/crs/EPSG/O/4258','http://www.opengis.net/def/crs/EPSG/0/4258')"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/4258">ETRS89</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='25831'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/25831">ETRS89 / UTM zone 31N</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='32631'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/32631">WGS 84 / UTM zone 31N</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='4258'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/4258">ETRS89</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='http://www.opengis.net/def/crs/EPSG/0/3035'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/3035">ETRS89-extended / LAEA Europe</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='3857'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/3857">WGS 84 / Pseudo-Mercator</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='WGS 84 / Pseudo-Mercator (EPSG:3857)'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/3857">WGS 84 / Pseudo-Mercator</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='4326'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/4326">WGS 84</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='23031'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/23031">ED50 / UTM zone 31N</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='21500'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/21500">Belge 1950 (Brussels) / Belge Lambert 50</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='23032'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/23032">ED50 / UTM zone 32N</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='4283'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/4283">GDA94</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='TAW'"><gmd:code><gmx:Anchor xlink:href="https://www.opengis.net/def/crs/EPSG/0/5710">Ostend height</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='LAT'"><gmd:code><gco:CharacterString>IHO-S44:LAT</gco:CharacterString></gmd:code></xsl:when>
			<xsl:when test="$code='1094'"><gmd:code><gmx:Anchor xlink:href="https://epsg.io/1094-datum">High Water</gmx:Anchor></gmd:code></xsl:when>
			<xsl:when test="$code='Onbekend'"><gmd:code><gco:CharacterString>Niet van toepassing</gco:CharacterString></gmd:code></xsl:when>
			<xsl:when test="$code='WGS 1984'"><gmd:code><gco:CharacterString>Onbekend</gco:CharacterString></gmd:code></xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
