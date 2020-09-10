<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:aiv-utils="http://metadata.vlaanderen.be/xsl/functions/profiles/iso19139"
                version="2.0" exclude-result-prefixes="#all">

  <xsl:variable name="schemaLocationFor2007"
                select="'http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd'"/>

  <xsl:variable name="isUsing2005Schema" select="true()"/>
  <xsl:variable name="isUsing2007Schema" select="false()"/>

  <!-- The default language is also added as gmd:locale
  for multilingual metadata records. -->
  <xsl:variable name="mainLanguage"
                select="/*/gmd:language/gco:CharacterString/text()|
                        /*/gmd:language/gmd:LanguageCode/@codeListValue"/>

  <xsl:variable name="locales"
                select="/*/gmd:locale/gmd:PT_Locale"/>

  <!-- We use the category check to find out if this is an SDS metadata. Please replace with anything better -->
  <xsl:variable name="isSDS"
                select="count(//gmd:DQ_DomainConsistency/gmd:result/gmd:DQ_ConformanceResult/gmd:specification/gmd:CI_Citation/gmd:title/gmx:Anchor[starts-with(@xlink:href, 'http://inspire.ec.europa.eu/metadata-codelist/Category')]) = 1"/>


  <xsl:template name="add-namespaces">
    <xsl:namespace name="xsi" select="'http://www.w3.org/2001/XMLSchema-instance'"/>
    <xsl:namespace name="gco" select="'http://www.isotc211.org/2005/gco'"/>
    <xsl:namespace name="gmd" select="'http://www.isotc211.org/2005/gmd'"/>
    <xsl:namespace name="gmx" select="'http://www.isotc211.org/2005/gmx'"/>
    <xsl:namespace name="gts" select="'http://www.isotc211.org/2005/gts'"/>
    <xsl:namespace name="gsr" select="'http://www.isotc211.org/2005/gsr'"/>
    <xsl:namespace name="gmi" select="'http://www.isotc211.org/2005/gmi'"/>
    <xsl:if test="gmd:identificationInfo/srv:SV_ServiceIdentification">
      <xsl:namespace name="srv" select="'http://www.isotc211.org/2005/srv'"/>
    </xsl:if>
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


  <xsl:template match="gmd:MD_Metadata">
    <xsl:copy copy-namespaces="no">
      <xsl:call-template name="add-namespaces"/>

      <xsl:choose>
        <xsl:when test="$isUsing2005Schema">
          <xsl:apply-templates select="@*[name() != 'xsi:schemaLocation']"/>
          <xsl:attribute name="xsi:schemaLocation"
                         select="'http://www.isotc211.org/2005/gmx http://schemas.opengis.net/iso/19139/20060504/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd'"/>
        </xsl:when>
        <xsl:when test="$isUsing2007Schema">
          <xsl:apply-templates select="@*[name() != 'xsi:schemaLocation']"/>
          <xsl:attribute name="xsi:schemaLocation"
                         select="'http://www.isotc211.org/2005/gmx http://schemas.opengis.net/iso/19139/20070417/gmx/gmx.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20070417/srv/1.0/srv.xsd http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20070417/gmd/gmd.xsd'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@*"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:apply-templates select="gmd:fileIdentifier"/>
      <xsl:apply-templates select="gmd:language"/>
      <xsl:apply-templates select="gmd:characterSet"/>
      <xsl:apply-templates select="gmd:parentIdentifier"/>
      <xsl:apply-templates select="
        gmd:hierarchyLevel|
        gmd:hierarchyLevelName|
        gmd:contact|
        gmd:dateStamp|
        gmd:metadataStandardName|
        gmd:metadataStandardVersion|
        gmd:dataSetURI"/>
      <xsl:apply-templates select="gmd:locale"/>
      <xsl:apply-templates select="
        gmd:spatialRepresentationInfo|
        gmd:referenceSystemInfo|
        gmd:metadataExtensionInfo|
        gmd:identificationInfo|
        gmd:contentInfo|
        gmd:distributionInfo|
        gmd:dataQualityInfo|
        gmd:portrayalCatalogueInfo|
        gmd:metadataConstraints|
        gmd:applicationSchemaInfo|
        gmd:metadataMaintenance|
        gmd:series|
        gmd:describes|
        gmd:propertyType|
        gmd:featureType|
        gmd:featureAttribute"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <!-- Only set metadataStandardName and metadataStandardVersion
    if not set. -->
  <xsl:template match="gmd:metadataStandardName[@gco:nilReason='missing' or gco:CharacterString='']"
                priority="10">
    <xsl:copy copy-namespaces="no">
      <gco:CharacterString>ISO 19115:2003/19139</gco:CharacterString>
    </xsl:copy>
  </xsl:template>

  <xsl:template
    match="gmd:metadataStandardVersion[@gco:nilReason='missing' or gco:CharacterString='']"
    priority="10">
    <xsl:copy copy-namespaces="no">
      <gco:CharacterString>1.0</gco:CharacterString>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template
    match="gmd:topicCategory[not(gmd:MD_TopicCategoryCode)]"
    priority="10"/>

  <!-- ================================================================= -->

  <xsl:template match="@gml:id|@gml320:id">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="{if ($isUsing2005Schema and not($isUsing2007Schema)) then 'gml320' else 'gml'}:id">
          <xsl:value-of select="generate-id(.)"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." copy-namespaces="no"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ==================================================================== -->
  <!-- Fix srsName attribute generate CRS:84 (EPSG:4326 with long/lat
         ordering) by default -->

  <xsl:template match="@srsName">
    <xsl:choose>
      <xsl:when test="normalize-space(.)=''">
        <xsl:attribute name="srsName">
          <xsl:text>CRS:84</xsl:text>
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." copy-namespaces="no"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Add required gml attributes if missing -->
  <xsl:template match="gml:Polygon[not(@gml:id) and not(@srsName)]|
                       gml:MultiSurface[not(@gml:id) and not(@srsName)]|
                       gml:LineString[not(@gml:id) and not(@srsName)]|
                       gml320:Polygon[not(@gml320:id) and not(@srsName)]">
    <xsl:copy copy-namespaces="no">
      <xsl:choose>
        <xsl:when test="$isUsing2005Schema and not($isUsing2007Schema)">
          <xsl:namespace name="gml320" select="'http://www.opengis.net/gml'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:namespace name="gml" select="'http://www.opengis.net/gml/3.2'"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:attribute name="{if ($isUsing2005Schema and not($isUsing2007Schema))
                            then 'gml320' else 'gml'}:id">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:attribute>
      <xsl:attribute name="srsName">
        <xsl:text>urn:ogc:def:crs:EPSG:6.6:4326</xsl:text>
      </xsl:attribute>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*"/>
    </xsl:copy>
  </xsl:template>

  <!-- INSPIRE / TG2 / Require nilReason attribute to be
  innaplicable or unknown when version is empty.
  Instead of the default missing -->
  <xsl:template match="gmd:distributionInfo/*/gmd:distributionFormat/*/gmd:version[gco:CharacterString = '']"
                priority="10">
    <gmd:version gco:nilReason="unknown">
      <gco:CharacterString/>
    </gmd:version>
  </xsl:template>

  <!-- ================================================================= -->
  <!-- codelists: set @codeList path -->
  <!-- ================================================================= -->
  <xsl:template match="gmd:LanguageCode[@codeListValue]" priority="10">
    <gmd:LanguageCode codeList="https://www.loc.gov/standards/iso639-2/">
      <xsl:apply-templates select="@*[name(.)!='codeList']"/>
    </gmd:LanguageCode>
  </xsl:template>

  <!--  only accept the pointOfContact role code for a gmd:contact element -->
  <xsl:template match="gmd:role[name(../..)='gmd:contact']" priority="100">
    <gmd:role>
      <gmd:CI_RoleCode codeList="https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#CI_RoleCode" codeListValue="pointOfContact"/>
    </gmd:role>
  </xsl:template>

  <xsl:template match="gmd:*[@codeListValue]">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*[name(.)!='codeList']"/>
      <xsl:attribute name="codeList">
        <xsl:value-of
          select="concat('https://standards.iso.org/iso/19139/resources/gmxCodelists.xml#',local-name(.))"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="srv:SV_CouplingType[@codeListValue]|srv:DCPList[@codeListValue]">
    <xsl:copy>
      <xsl:apply-templates select="@*[name(.)!='codeList']"/>
      <xsl:attribute name="codeList">
        <xsl:value-of
          select="concat('https://standards.iso.org/iso/19115/resources/Codelists/gml/',local-name(.),'.xml')"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <!-- can't find the location of the 19119 codelists - so we make one up -->
  <!--xsl:template match="srv:*[@codeListValue]">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*[name(.)!='codeList']"/>
      <xsl:attribute name="codeList">
        <xsl:value-of
          select="concat('http://www.isotc211.org/2005/iso19119/resources/Codelist/gmxCodelists.xml#',local-name(.))"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template-->

  <!-- For XLinked subtemplates, the lang parameter MUST be in the same order as in the record.
Main language first, then other locales. If not, then the default CharacterString does not contain
the main language. It user change the language order in the record, the lang parameter needs to
be reordered too.

Example of URL:
<gmd:pointOfContact xmlns:xlink="http://www.w3.org/1999/xlink"
                           xlink:href="local://srv/api/registries/entries/af9e5d4e-2c1a-48c0-853f-3a771fcf9ee3?
                             process=gmd:role/gmd:CI_RoleCode/@codeListValue~distributor&amp;
                             lang=eng,ara,spa,rus,fre,ger,chi&amp;
                             schema=iso19139"
Can also be using lang=eng&amp;lang=ara.
-->
  <xsl:template match="@xlink:href[starts-with(., 'local://srv/api/registries/entries') and contains(., '?')]">
    <xsl:variable name="urlBase"
                  select="substring-before(., '?')"/>
    <xsl:variable name="urlParameters"
                  select="substring-after(., '?')"/>

    <!-- Collect all parameters excluding language -->
    <xsl:variable name="listOfAllParameters">
      <xsl:for-each select="tokenize($urlParameters, '&amp;')">
        <xsl:variable name="parameterName"
                      select="tokenize(., '=')[1]"/>

        <xsl:if test="$parameterName != 'lang'">
          <param name="{$parameterName}"
                 value="{.}"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:attribute name="xlink:href"
                   select="concat(
                    $urlBase,
                    '?lang=', string-join(($mainLanguage, $locales//gmd:LanguageCode/@codeListValue[. != $mainLanguage]), ','),
                    '&amp;',
                    string-join($listOfAllParameters/param/@value, '&amp;'))"/>
  </xsl:template>

  <!-- ================================================================= -->
  <!-- Set local identifier to the first 2 letters of iso code. Locale ids
        are used for multilingual charcterString using #iso2code for referencing.
    -->
  <xsl:template match="gmd:PT_Locale">
    <xsl:element name="gmd:{local-name()}">
      <xsl:variable name="id"
                    select="upper-case(aiv-utils:twoCharLangCode(gmd:languageCode/gmd:LanguageCode/@codeListValue))"/>

      <xsl:apply-templates select="@*"/>
      <xsl:if test="normalize-space(@id)='' or normalize-space(@id)!=$id">
        <xsl:attribute name="id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="node()"/>
    </xsl:element>
  </xsl:template>

  <!-- Remove attribute indeterminatePosition having empty
     value which is not a valid facet for it. -->
  <xsl:template match="@indeterminatePosition[. = '']" priority="2"/>


  <!-- ================================================================= -->
  <!-- Adjust the namespace declaration - In some cases name() is used to get the
        element. The assumption is that the name is in the format of  <ns:element>
        however in some cases it is in the format of <element xmlns=""> so the
        following will convert them back to the expected value. This also corrects the issue
        where the <element xmlns=""> loose the xmlns="" due to the exclude-result-prefixes="#all" -->
  <!-- Note: Only included prefix gml, gmd and gco for now. -->
  <!-- TODO: Figure out how to get the namespace prefix via a function so that we don't need to hard code them -->
  <!-- ================================================================= -->
  <xsl:template name="correct_ns_prefix">
    <xsl:param name="element"/>
    <xsl:param name="prefix"/>
    <xsl:choose>
      <xsl:when test="local-name($element)=name($element) and $prefix != '' ">
        <xsl:element name="{$prefix}:{local-name($element)}">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy copy-namespaces="no">
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="gmd:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gmd'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="gco:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix" select="'gco'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Move to GML 3.2.1 when using 2007 version. -->
  <xsl:template match="gml320:*[$isUsing2007Schema]">
    <xsl:element name="gml:{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="@gml320:*[$isUsing2007Schema]">
    <xsl:attribute name="gml:{local-name()}" select="."/>
  </xsl:template>

  <xsl:template match="gml:*|gml320:*">
    <xsl:call-template name="correct_ns_prefix">
      <xsl:with-param name="element" select="."/>
      <xsl:with-param name="prefix"
                      select="if ($isUsing2005Schema and not($isUsing2007Schema)) then 'gml320' else 'gml'"/>
    </xsl:call-template>
  </xsl:template>


  <!-- Only gmd:referenceSystemIdentifier can have a gmd:RS_Identifier child element, all other RS_Identifier elements
      must be transformed to a MD:Identifier and existing child elements gmd:codeSpace and gmd:version must be removed -->
  <xsl:template match="gmd:RS_Identifier[not(name(..)='gmd:referenceSystemIdentifier')]" priority="100">
    <gmd:MD_Identifier>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*[not(name(.)='gmd:codeSpace' or name(.)='gmd:version')]"/>
    </gmd:MD_Identifier>
  </xsl:template>


  <!-- ================================================================= -->
  <!-- SDS fixes -->

  <!-- DCP codelist -->
  <xsl:template match="srv:DCP[$isSDS]/srv:DCPList[@codeListValue]">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="codeList">
        <xsl:value-of select="'http://inspire.ec.europa.eu/metadata-codelist/DCPList'"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <!-- Remove geographic/temporal extent if doesn't contain child elements.
     Used to clean up the element, for example when removing the the temporal extent
     in the editor, to avoid an element like <gmd:extent><gmd:EX_Extent></gmd:EX_Extent></gmd:extent>,
     that causes a validation error in schematron iso: [ISOFTDS19139:2005-TableA1-Row23] - Extent element required
-->
  <xsl:template match="gmd:extent[gmd:EX_Extent/not(*)]|srv:extent[gmd:EX_Extent/not(*)]"/>


  <xsl:template match="gmd:dateTime" priority="200">
    <xsl:variable name="child" select="string(gco:Date|gco:DateTime)"/>
    <xsl:copy copy-namespaces="no">
      <xsl:if test="normalize-space($child) = ''">
        <xsl:attribute name="gco:nilReason" select="'missing'"/>
      </xsl:if>
      <xsl:if test="not(normalize-space($child) = '')">
        <gco:DateTime>
          <xsl:value-of select="$child"/>
        </gco:DateTime>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[gco:DateTime]" priority="100">
    <xsl:variable name="child" select="string(gco:DateTime)"/>
    <xsl:copy copy-namespaces="no">
      <xsl:if test="normalize-space($child) = ''">
        <xsl:attribute name="gco:nilReason" select="'missing'"/>
      </xsl:if>
      <xsl:if test="not(normalize-space($child) = '')">
        <xsl:apply-templates select="@*|node()"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*[gco:Date]" priority="100">
    <xsl:variable name="child" select="string(gco:Date)"/>
    <xsl:copy copy-namespaces="no">
      <xsl:if test="normalize-space($child) = ''">
        <xsl:attribute name="gco:nilReason" select="'missing'"/>
      </xsl:if>
      <xsl:if test="not(normalize-space($child) = '')">
        <xsl:apply-templates select="@*|node()"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="gmd:pass" priority="100">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="not(gco:Boolean) or normalize-space(gco:Boolean) = ''">
          <xsl:attribute name="gco:nilReason" select="'unknown'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@*[not(name() = 'gco:nilReason')]|*"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>


  <!-- ================================================================== -->
  <!-- =================         FUNCTION         ======================= -->
  <!-- ================================================================== -->
  <xsl:function name="aiv-utils:twoCharLangCode">
    <xsl:param name="lang3Char"/>
    <xsl:choose>
      <xsl:when test="lower-case($lang3Char) = 'fre' or lower-case($lang3Char) = 'fra'">
        <xsl:value-of select="'fr'"/>
      </xsl:when>
      <xsl:when test="lower-case($lang3Char) = 'dut'">
        <xsl:value-of select="'nl'"/>
      </xsl:when>
      <xsl:when test="lower-case($lang3Char) = 'eng'">
        <xsl:value-of select="'en'"/>
      </xsl:when>
      <xsl:when test="lower-case($lang3Char) = 'ger'">
        <xsl:value-of select="'de'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="lower-case($lang3Char)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
