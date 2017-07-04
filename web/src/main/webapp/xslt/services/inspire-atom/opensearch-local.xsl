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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:template match="/">
    <OpenSearchDescription xmlns:inspire_dls="http://inspire.ec.europa.eu/schemas/inspire_dls/1.0"
                           xmlns="http://a9.com/-/spec/opensearch/1.1/">


      <!--URL of this document-->
      <xsl:choose>
        <xsl:when test="string(/root/response/fileId)">
          <ShortName>INSPIRE Download</ShortName>
          <LongName><xsl:value-of select="substring(/root/response/title,1,48)"/></LongName>
          <Description><xsl:value-of select="/root/response/title"/>: <xsl:value-of select="/root/response/subtitle"/></Description>

          <Url type="application/opensearchdescription+xml" rel="self">
            <xsl:attribute name="template">
              <xsl:value-of
                select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/', /root/response/fileId,'/OpenSearchDescription.xml')"/>
            </xsl:attribute>
          </Url>

                    <!--Generic URL template for browser integration-->
<!--
                    <Url type="application/atom+xml" rel="results">
                        <xsl:attribute name="template">
                            <xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/', /root/response/fileId,'/describe')"/>
                        </xsl:attribute>
                    </Url>
-->

                    <!--Generic URL template for browser integration-->
                    <Url type="text/html" rel="results">
                        <xsl:attribute name="template">
                            <xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/', /root/response/fileId,'/htmlsearch?q={searchTerms?}')"/>
                        </xsl:attribute>
                    </Url>
        </xsl:when>
        <xsl:otherwise>
                    <ShortName>INSPIRE Download</ShortName>
                    <LongName><xsl:value-of select="substring(//site/organization,1,24)"/> | GeoNetwork opensource</LongName>
                    <Description><xsl:value-of select="/root/gui/strings/opensearch"/></Description>

                    <!--Generic URL template for browser integration-->
                    <Url type="application/xml" rel="results">
                        <xsl:attribute name="template">
                            <xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/search?q={searchTerms?}')"/>
                        </xsl:attribute>
                    </Url>
        </xsl:otherwise>
      </xsl:choose>

			<!--Describe Spatial Data Set Operation request URL template to be used
			    in order to retrieve the Description of Spatial Object Types in a Spatial
			    Dataset-->
			<Url type="application/atom+xml" rel="describedby">
			    <xsl:attribute name="template">
					<xsl:value-of select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/describe?spatial_dataset_identifier_code={inspire_dls:spatial_dataset_identifier_code?}&amp;spatial_dataset_identifier_namespace={inspire_dls:spatial_dataset_identifier_namespace?}&amp;crs={inspire_dls:crs?}&amp;language={language?}&amp;q={searchTerms?}')"/>
				</xsl:attribute>
            </Url>
			
			<xsl:variable name="url" select="concat(//server/protocol,'://',//server/host,/root/gui/url,'/opensearch/', /root/gui/language, '/download?spatial_dataset_identifier_code={inspire_dls:spatial_dataset_identifier_code?}&amp;spatial_dataset_identifier_namespace={inspire_dls:spatial_dataset_identifier_namespace?}&amp;crs={inspire_dls:crs?}&amp;language={language?}&amp;q={searchTerms?}')"/>
			<Url type="application/atom+xml" rel="results">
			    <xsl:attribute name="template"><xsl:value-of select="$url"/></xsl:attribute>
			</Url>
			<Url type="application/x-shapefile" rel="results">
			    <xsl:attribute name="template"><xsl:value-of select="$url"/></xsl:attribute>
			</Url>
			<Url type="application/x-gmz" rel="results">
			    <xsl:attribute name="template"><xsl:value-of select="$url"/></xsl:attribute>
			</Url>


      <!-- Repeat the following for each data set, for each CRS of a dataset query example (regardless of the number of file formats -->
            <!-- Repeat the following for each data set, for each CRS of a dataset query example (regardless of the number of file formats -->
            <xsl:for-each select="/root/response/datasets/dataset">
                <xsl:variable name="codeVal" select="code" />
                <xsl:variable name="namespaceVal" select="namespace" />

                <xsl:for-each select="file">
                    <Query role="example"
                           inspire_dls:spatial_dataset_identifier_namespace="{$namespaceVal}"
                           inspire_dls:spatial_dataset_identifier_code="{$codeVal}" inspire_dls:crs="{crs}" language="{lang}" title="{title}" count="{crsCount}"/>
                </xsl:for-each>

            </xsl:for-each>

      <xsl:choose>
        <xsl:when test="string(/root/response/fileId)">
          <!-- For each Service Feed the contact -->
          <Contact><xsl:value-of select="/root/response/authorEmail" /></Contact>
          <Tags>
            <xsl:value-of select="/root/response/keywords"/>
          </Tags>
          <!-- per Atom Service feed / Service metadata record combinatie: -->
          <Developer>
            <xsl:value-of select="/root/response/authorName"/>
          </Developer>
          <!--Languages supported by the service. The first language is the default language-->
          <!-- And for each language of the Service Feed: -->
          <Language>
            <xsl:value-of select="/root/response/lang"/>
          </Language>
        </xsl:when>
        <xsl:otherwise>
          <Contact>
            <xsl:value-of select="//feedback/email"/>
          </Contact>
          <Language>
            <xsl:value-of select="/root/gui/language"/>
          </Language>
        </xsl:otherwise>
      </xsl:choose>


    </OpenSearchDescription>
  </xsl:template>
</xsl:stylesheet>
