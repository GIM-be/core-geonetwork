<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:gml320="http://www.opengis.net/gml"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                xmlns:xslUtils="java:org.fao.geonet.util.XslUtil"
                xmlns:gn-fn-iso19139="http://geonetwork-opensource.org/xsl/functions/profiles/iso19139"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all">

  <xsl:include href="../../index-fields/inspire-util.xsl"/>
  <xsl:include href="min-utility-fn.xsl"/>
  <xsl:include href="variables.xsl"/>
  <xsl:include href="starting-point.xsl"/>
  <xsl:include href="sharedFormatterDir/xslt/render-functions.xsl"/>


  <xsl:template mode="render-content" match="*|@*">
    <!-- Ignore everything else -->
    <xsl:message select="concat('Ignoring ', name(..), '/', name(.))"/>
  </xsl:template>

  <!-- Ignore some fields displayed in header or in right column -->
  <xsl:template mode="render-content"
                match="gmd:graphicOverview|gmd:abstract|gmd:title[name(../..)='gmd:citation']"
                priority="2000">
    <xsl:message select="concat('Ignoring ', name(..), '/', name(.), ' displayed in the header or right column')"/>
  </xsl:template>

  <!-- =============================================  -->
  <!-- Content templates                              -->
  <!-- Responsible for the order of the elements      -->
  <!-- =============================================  -->
  <xsl:template mode="render-content" match="gmd:MD_Metadata">
    <!-- Display content of every tabs -->
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-identificationTab'"/>
      <xsl:with-param name="content">
        <xsl:call-template name="render-block">
          <xsl:with-param name="block">
            <xsl:apply-templates mode="render-content" select="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-contentTab'"/>
      <xsl:with-param name="content">
        <xsl:apply-templates mode="render-content" select="gmd:identificationInfo/*"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-referenceSystemTab'"/>
      <xsl:with-param name="content">
        <xsl:apply-templates mode="render-content" select="gmd:referenceSystemInfo"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="mdDataQuality" select="gmd:dataQualityInfo/gmd:DQ_DataQuality"/>
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-qualityTab'"/>
      <xsl:with-param name="content">
        <xsl:call-template name="render-block">
          <xsl:with-param name="block">
            <xsl:apply-templates mode="render-content" select="$mdDataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode"/>
            <xsl:apply-templates mode="render-content" select="$mdDataQuality/gmd:scope/gmd:DQ_Scope/gmd:levelDescription/gmd:MD_ScopeDescription/gmd:other"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates mode="render-content" select="$mdDataQuality/gmd:report/*[name()=('gmd:DQ_ThematicClassificationCorrectness','gmd:DQ_CompletenessOmission','gmd:DQ_CompletenessCommission','gmd:DQ_AbsoluteExternalPositionalAccuracy')]"/>
        <xsl:apply-templates mode="render-content" select="$mdDataQuality/gmd:lineage"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-domainConsistancyTab'"/>
      <xsl:with-param name="content">
        <xsl:apply-templates mode="render-content" select="$mdDataQuality/gmd:report/gmd:DQ_DomainConsistency"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-constraintsTab'"/>
      <xsl:with-param name="content">
        <xsl:call-template name="render-block">
          <xsl:with-param name="header" select="gn-fn-iso19139:get-schema-strings($schemaStrings, 'mdLegalAndSecurityConstraintsSection')"/>
          <xsl:with-param name="block">
            <xsl:apply-templates mode="render-content" select="gmd:identificationInfo/*/gmd:resourceConstraints/*[name()=('gmd:MD_LegalConstraints','gmd:MD_SecurityConstraints')]"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-distributionTab'"/>
      <xsl:with-param name="content">
        <xsl:call-template name="render-block">
          <xsl:with-param name="block">
            <xsl:apply-templates mode="render-content" select="gmd:distributionInfo/gmd:MD_Distribution"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-metaMetadataTab'"/>
      <xsl:with-param name="content">
        <xsl:call-template name="render-block">
          <xsl:with-param name="block">
            <xsl:apply-templates mode="render-content" select="gmd:fileIdentifier"/>
            <xsl:apply-templates mode="render-content" select="gmd:language/gmd:LanguageCode"/>
            <xsl:apply-templates mode="render-content" select="gmd:characterSet/gmd:MD_CharacterSetCode"/>
            <xsl:apply-templates mode="render-content" select="gmd:parentIdentifier"/>
            <xsl:apply-templates mode="render-content" select="gmd:hierarchyLevel/gmd:MD_ScopeCode"/>
            <xsl:apply-templates mode="render-content" select="gmd:hierarchyLevelName"/>
            <xsl:apply-templates mode="render-content" select="gmd:dateStamp"/>
            <xsl:apply-templates mode="render-content" select="gmd:metadataStandardName"/>
            <xsl:apply-templates mode="render-content" select="gmd:metadataStandardVersion"/>
            <xsl:call-template name="render-block-as-row-with-header">
              <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:contact', name())"/>
              <xsl:with-param name="block">
                <xsl:apply-templates mode="render-content" select="gmd:contact/gmd:CI_ResponsibleParty"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-tab">
      <xsl:with-param name="tabId" select="'gn-tab-objectCatalogueTab'"/>
      <xsl:with-param name="content">
        <xsl:apply-templates mode="render-content" select="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- =============================================  -->
  <!-- Render Sections for each tab                   -->
  <!-- =============================================  -->
  <xsl:template mode="render-content" match="gmd:identificationInfo/*/gmd:citation/gmd:CI_Citation|gmd:aggregationInfo/gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation">
    <xsl:apply-templates mode="render-content" select="gmd:title"/>
    <xsl:apply-templates mode="render-content" select="gmd:alternateTitle"/>
    <xsl:apply-templates mode="render-content" select="gmd:date" />
    <xsl:apply-templates mode="render-content" select="gmd:edition"/>
    <xsl:apply-templates mode="render-content" select="gmd:editionDate"/>
    <xsl:for-each select="gmd:identifier">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, 'gmd:code', '/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier/gmd:MD_Identifier/gmd:code')"/>
        <xsl:with-param name="content" select="*/gmd:code/gco:CharacterString/text()"/>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:apply-templates mode="render-content" select="gmd:series/gmd:CI_Series/gmd:name"/>
    <!--
    Optional fields and not used
    <xs:element name="citedResponsibleParty" type="gmd:CI_ResponsibleParty_PropertyType"
                minOccurs="0" maxOccurs="unbounded"/>
    <xs:element name="presentationForm" type="gmd:CI_PresentationFormCode_PropertyType"
                minOccurs="0" maxOccurs="unbounded"/>
    <xs:element name="series" type="gmd:CI_Series_PropertyType" minOccurs="0"/>
    <xs:element name="otherCitationDetails" type="gco:CharacterString_PropertyType"
                minOccurs="0"/>
    <xs:element name="collectiveTitle" type="gco:CharacterString_PropertyType" minOccurs="0"/>
    <xs:element name="ISBN" type="gco:CharacterString_PropertyType" minOccurs="0"/>
    <xs:element name="ISSN" type="gco:CharacterString_PropertyType" minOccurs="0"/>
    -->
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:identificationInfo/*">
    <xsl:call-template name="render-block">
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:abstract"/>
        <xsl:apply-templates mode="render-content" select="gmd:purpose"/>
        <xsl:apply-templates mode="render-content" select="gmd:credit"/>
        <xsl:apply-templates mode="render-content" select="gmd:status/gmd:MD_ProgressCode"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="count(gmd:resourceConstraints/gmd:MD_Constraints[gmd:useLimitation/*[normalize-space()!='']])>0">
      <xsl:call-template name="render-block">
        <xsl:with-param name="header" select="gn-fn-iso19139:get-schema-strings($schemaStrings, 'mdConstraintsSection')"/>
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="gmd:resourceConstraints/gmd:MD_Constraints[gmd:useLimitation/*[normalize-space()!='']]"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:for-each select="gmd:pointOfContact">
      <xsl:call-template name="render-block">
        <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:pointOfContact', name())"/>
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="gmd:CI_ResponsibleParty"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="count(gmd:resourceMaintenance) + count(gmd:resourceFormat) > 0">
      <xsl:call-template name="render-block">
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="gmd:resourceMaintenance"/>
          <xsl:apply-templates mode="render-content" select="gmd:graphicOverview"/>
          <xsl:apply-templates mode="render-content" select="gmd:resourceFormat"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:descriptiveKeywords', name())"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:descriptiveKeywords[*/gmd:thesaurusName/gmd:CI_Citation/gmd:title and count(gmd:MD_Keywords/gmd:keyword/*[normalize-space()!=''])>0]"/>
        <xsl:apply-templates mode="render-content" select="gmd:descriptiveKeywords[not(*/gmd:thesaurusName/gmd:CI_Citation/gmd:title) and count(gmd:MD_Keywords/gmd:keyword/*[normalize-space()!=''])>0]"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="render-block">
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="srv:serviceType/gco:LocalName"/>
        <xsl:apply-templates mode="render-content" select="srv:serviceTypeVersion"/>
        <xsl:apply-templates mode="render-content" select="srv:extent"/>
        <xsl:apply-templates mode="render-content" select="srv:coupledResource"/>
        <xsl:apply-templates mode="render-content" select="srv:couplingType/srv:SV_CouplingType"/>
        <xsl:if test="$formatter!='default'">
          <xsl:apply-templates mode="render-content" select="srv:accessProperties"/>
        </xsl:if>
        <xsl:apply-templates mode="render-content" select="srv:containsOperations"/>
        <xsl:apply-templates mode="render-content" select="srv:operatesOn"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:for-each select="gmd:resourceSpecificUsage">
      <xsl:call-template name="render-block">
        <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="gmd:MD_Usage"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="gmd:aggregationInfo">
      <xsl:call-template name="render-block">
        <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:aggregationInfo', name())"/>
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="gmd:MD_AggregateInformation/gmd:aggregateDataSetName/gmd:CI_Citation"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:call-template name="render-block">
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:for-each select="gmd:spatialResolution">
      <xsl:call-template name="render-block">
        <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="gmd:MD_Resolution/gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:call-template name="render-block">
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:language/gmd:LanguageCode"/>
        <xsl:apply-templates mode="render-content" select="gmd:characterSet/gmd:MD_CharacterSetCode"/>
        <xsl:if test="count(gmd:topicCategory/gmd:MD_TopicCategoryCode) > 0">
          <xsl:call-template name="render-block-as-row">
            <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, 'gmd:MD_TopicCategoryCode', 'gmd:topicCategory')"/>
            <xsl:with-param name="block">
              <xsl:for-each select="gmd:topicCategory/gmd:MD_TopicCategoryCode">
                <button class="btn btn-sm btn-default">
                  <xsl:attribute name="data-ng-click" select="concat('search({''topicCat'':''',.,'''})')"/>
                  <xsl:attribute name="title" select="concat('{{''clickToFilterOn'' | translate}} {{''',.,''' | translate}}')"/>
                  <span class="{concat('fa gn-icon-',.,' topic-color')}"/><xsl:value-of select="concat('{{''',.,''' | translate}}')" />
                </button>
              </xsl:for-each>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates mode="render-content" select="gmd:environmentDescription"/>
        <xsl:apply-templates mode="render-content" select="gmd:supplementalInformation"/>
        <xsl:apply-templates mode="render-content" select="gmd:extent"/>
        <!--
        Optional fields for service and not used
        <xs:element name="restrictions" type="gmd:MD_Constraints_PropertyType" minOccurs="0"/>
        <xs:element name="keywords" type="gmd:MD_Keywords_PropertyType" minOccurs="0"
                    maxOccurs="unbounded"/>
        -->
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:referenceSystemInfo">
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:referenceSystemInfo', name(..))"/>
      <xsl:with-param name="block">
        <xsl:variable name="referenceSystemIdentifier" select="gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier"/>
        <xsl:variable name="code" select="$referenceSystemIdentifier/*/gmd:code"/>
        <xsl:variable name="value" select="$code/*/text()"/>
        <xsl:variable name="link" select="$code/gmx:Anchor/@xlink:href"/>
        <xsl:if test="$link!=''">
          <xsl:call-template name="render-anchor-as-row">
            <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, 'gmx:Anchor', 'gmd:code')"/>
            <xsl:with-param name="link" select="$link"/>
            <xsl:with-param name="value" select="$value"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="not($link!='')">
          <xsl:call-template name="render-row">
            <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, 'gmd:code', '/gmd:MD_Metadata/gmd:referenceSystemInfo/gmd:MD_ReferenceSystem/gmd:referenceSystemIdentifier/gmd:RS_Identifier/gmd:code')"/>
            <xsl:with-param name="content" select="$value"/>
          </xsl:call-template>
          <xsl:apply-templates mode="render-content" select="$referenceSystemIdentifier/gmd:RS_Identifier/gmd:codeSpace"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/*[name()=('gmd:DQ_ThematicClassificationCorrectness','gmd:DQ_CompletenessOmission','gmd:DQ_CompletenessCommission','gmd:DQ_AbsoluteExternalPositionalAccuracy')]">
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:measureDescription"/>
        <xsl:apply-templates mode="render-content" select="gmd:dateTime"/>
        <xsl:variable name="quantitativeResult"  select="gmd:result/gmd:DQ_QuantitativeResult"/>
        <xsl:call-template name="render-block-as-row-with-header">
          <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:DQ_QuantitativeResult', 'gmd:result')"/>
          <xsl:with-param name="block">
            <xsl:apply-templates mode="render-content" select="$quantitativeResult/gmd:valueUnit/gml:UnitDefinition/gml:identifier"/>
            <xsl:apply-templates mode="render-content" select="$quantitativeResult/gmd:value/gco:Record"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:lineage">
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:LI_Lineage/gmd:statement"/>
        <xsl:for-each select="gmd:LI_Lineage/gmd:processStep">
          <xsl:variable name="processStep"  select="."/>
          <xsl:call-template name="render-block-as-row-with-header">
            <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
            <xsl:with-param name="block">
              <xsl:apply-templates mode="render-content" select="$processStep/gmd:LI_ProcessStep/gmd:description"/>
              <xsl:apply-templates mode="render-content" select="$processStep/gmd:LI_ProcessStep/gmd:dateTime"/>
              <xsl:call-template name="render-block-as-row-with-header">
                <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:processor', 'gmd:LI_ProcessStep')"/>
                <xsl:with-param name="block">
                  <xsl:apply-templates mode="render-content" select="$processStep/gmd:LI_ProcessStep/gmd:processor/gmd:CI_ResponsibleParty"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report/gmd:DQ_DomainConsistency">
    <xsl:call-template name="render-block">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:measureIdentification/*/gmd:code"/>
        <xsl:apply-templates mode="render-content" select="gmd:measureDescription"/>
        <xsl:apply-templates mode="render-content" select="gmd:dateTime"/>
        <xsl:variable name="conformanceResult"  select="gmd:result/gmd:DQ_ConformanceResult"/>
        <xsl:call-template name="render-block-as-row-with-header">
          <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:DQ_ConformanceResult', 'gmd:result')"/>
          <xsl:with-param name="block">
            <xsl:call-template name="render-block-as-row-with-header">
              <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:specification', 'gmd:DQ_ConformanceResult')"/>
              <xsl:with-param name="block">
                <xsl:apply-templates mode="render-content" select="$conformanceResult/gmd:specification/gmd:CI_Citation/gmd:title"/>
                <xsl:apply-templates mode="render-content" select="$conformanceResult/gmd:specification/gmd:CI_Citation/gmd:date"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates mode="render-content" select="$conformanceResult/gmd:explanation"/>
            <xsl:apply-templates mode="render-content" select="$conformanceResult/gmd:pass"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:identificationInfo/*/gmd:resourceConstraints/*">
    <xsl:call-template name="render-block-as-row-with-header">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(..), name(../..))"/>
      <xsl:with-param name="block">
        <xsl:call-template name="render-block-as-row-with-header">
          <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
          <xsl:with-param name="block">
            <xsl:apply-templates mode="render-content" select="gmd:useLimitation"/>
            <xsl:apply-templates mode="render-content" select="gmd:accessConstraints/gmd:MD_RestrictionCode"/>
            <xsl:apply-templates mode="render-content" select="gmd:useConstraints/gmd:MD_RestrictionCode"/>
            <xsl:if test="count(gmd:otherConstraints) > 0">
              <xsl:call-template name="render-block-as-row-with-header">
                <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:otherConstraints', name())"/>
                <xsl:with-param name="block">
                  <xsl:apply-templates mode="render-content" select="gmd:otherConstraints"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates mode="render-content" select="gmd:classification/gmd:MD_ClassificationCode"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:MD_Distribution">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, 'gmd:distributionFormat', name())"/>
      <xsl:with-param name="value">
        <xsl:for-each select="gmd:distributionFormat/gmd:MD_Format/gmd:name/gco:CharacterString">
          <xsl:variable name="version" select="normalize-space(../../gmd:version/gco:CharacterString)" />
          <xsl:variable name="toolTip" select="concat('{{''clickToFilterOn'' | translate}} ', .)"/>
          <a>
            <xsl:attribute name="href" select="''"/>
            <xsl:attribute name="title" select="$toolTip"/>
            <xsl:attribute name="aria-label" select="$toolTip"/>
            <xsl:attribute name="data-ng-click"
                           select="concat('search({''format'':''',.,'''})')"/>
            <span class="badge">
              <xsl:if test="$version!=''">
                <xsl:value-of select="concat(.,' (Version: ', $version,')')"/>
              </xsl:if>
              <xsl:if test="not($version!='')">
                <xsl:value-of select="."/>
              </xsl:if>
            </span>
          </a>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:for-each select="gmd:distributor/gmd:MD_Distributor">
      <xsl:call-template name="render-block-as-row-with-header">
        <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:distributor', 'gmd:MD_Distribution')"/>
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="gmd:distributorContact/gmd:CI_ResponsibleParty"/>
          <xsl:for-each select="gmd:distributionOrderProcess/gmd:MD_StandardOrderProcess">
            <xsl:call-template name="render-block-as-row-with-header">
              <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:distributionOrderProcess', 'gmd:MD_Distributor')"/>
              <xsl:with-param name="block">
                <xsl:apply-templates mode="render-content" select="gmd:fees"/>
                <xsl:apply-templates mode="render-content" select="gmd:orderingInstructions"/>
                <xsl:apply-templates mode="render-content" select="gmd:turnaround"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
    <xsl:for-each select="gmd:transferOptions/gmd:MD_DigitalTransferOptions">
      <xsl:call-template name="render-block-as-row-with-header">
        <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:transferOptions', 'gmd:MD_Distribution')"/>
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="gmd:unitsOfDistribution"/>
          <xsl:for-each select="gmd:onLine">
            <xsl:call-template name="render-block-as-row-with-header">
              <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), 'gmd:MD_DigitalTransferOptions')"/>
              <xsl:with-param name="block">
                <xsl:apply-templates mode="render-content" select="gmd:CI_OnlineResource"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
          <xsl:apply-templates mode="render-content" select="gmd:offLine/gmd:MD_Medium/gmd:name/gmd:MD_MediumNameCode"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:contentInfo/gmd:MD_FeatureCatalogueDescription">
    <xsl:call-template name="render-block">
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:includedWithDataset"/>
        <xsl:call-template name="render-block-as-row-with-header">
          <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:featureCatalogueCitation', name())"/>
          <xsl:with-param name="block">
            <xsl:apply-templates mode="render-content" select="gmd:featureCatalogueCitation/@uuidref"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:CI_ResponsibleParty">
    <xsl:apply-templates mode="render-content" select="gmd:individualName"/>
    <xsl:apply-templates mode="render-content" select="gmd:organisationName"/>
    <xsl:for-each select="gmd:contactInfo/gmd:CI_Contact">
      <xsl:apply-templates mode="render-content" select="gmd:phone/gmd:CI_Telephone/gmd:voice"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:deliveryPoint"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:city"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:postalCode"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:country"/>
      <xsl:apply-templates mode="render-content" select="gmd:address/gmd:CI_Address/gmd:electronicMailAddress"/>
      <xsl:apply-templates mode="render-content" select="gmd:onlineResource/gmd:CI_OnlineResource/gmd:linkage"/>
    </xsl:for-each>
    <xsl:apply-templates mode="render-content" select="gmd:role/gmd:CI_RoleCode"/>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:resourceMaintenance">
    <xsl:apply-templates mode="render-content" select="gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency/gmd:MD_MaintenanceFrequencyCode"/>
    <xsl:apply-templates mode="render-content" select="gmd:MD_MaintenanceInformation/gmd:dateOfNextUpdate"/>
    <xsl:call-template name="render-block-as-row-with-header">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, 'gmd:contact', 'gmd:dateOfNextUpdate')"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="gmd:MD_MaintenanceInformation/gmd:contact/gmd:CI_ResponsibleParty"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:descriptiveKeywords">
    <xsl:variable name="thesaurusTitle" select="*/gmd:thesaurusName/gmd:CI_Citation/gmd:title/*"/>
    <xsl:variable name="isInspireThesaurus" select="$thesaurusTitle and $thesaurusTitle = ('gemet - inspire themes, version 1.0','GEMET - INSPIRE thema''s, versie 1.0')" />
    <xsl:call-template name="render-block-as-row">
      <xsl:with-param name="label" select="if ($thesaurusTitle) then $thesaurusTitle else gn-fn-iso19139:get-schema-strings($schemaStrings, 'otherKeywords')"/>
      <xsl:with-param name="block">
        <!--xsl:call-template name="render-text-as-row">
          <xsl:with-param name="label" select="gn-fn-iso19139:get-schema-strings($schemaStrings, 'otherKeywords')"/>
          <xsl:with-param name="value" select="string-join(*/gmd:keyword,', ')"/>
        </xsl:call-template-->
        <xsl:for-each select="*/gmd:keyword">
          <xsl:apply-templates mode="render-content" select="."/>
          <xsl:if test="not($isInspireThesaurus) and position() != last()">
            <div class="gp-inline"> | </div>
          </xsl:if>
        </xsl:for-each>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:CI_OnlineResource">
    <xsl:apply-templates mode="render-content" select="gmd:linkage"/>
    <xsl:apply-templates mode="render-content" select="gmd:protocol"/>
    <xsl:apply-templates mode="render-content" select="gmd:name"/>
    <xsl:apply-templates mode="render-content" select="gmd:description"/>
  </xsl:template>

  <xsl:template mode="render-content" match="srv:coupledResource">
    <xsl:call-template name="render-block-as-row-with-header">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="srv:SV_CoupledResource/srv:operationName"/>
        <xsl:apply-templates mode="render-content" select="srv:SV_CoupledResource/srv:identifier"/>
        <xsl:apply-templates mode="render-content" select="srv:SV_CoupledResource/gco:ScopedName"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="srv:containsOperations">
    <xsl:call-template name="render-block-as-row-with-header">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="srv:SV_OperationMetadata/srv:operationName"/>
        <xsl:apply-templates mode="render-content" select="srv:SV_OperationMetadata/srv:DCP/srv:DCPList"/>
        <xsl:apply-templates mode="render-content" select="srv:SV_OperationMetadata/srv:connectPoint/gmd:CI_OnlineResource"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="srv:operatesOn">
    <xsl:call-template name="render-block-as-row-with-header">
      <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="block">
        <xsl:apply-templates mode="render-content" select="@uuidref"/>
        <xsl:call-template name="render-url-as-row">
          <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, 'xlink:href', name())"/>
          <xsl:with-param name="url" select="@xlink:href"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:MD_Usage">
    <xsl:apply-templates mode="render-content" select="gmd:specificUsage"/>
    <xsl:for-each select="gmd:userContactInfo/gmd:CI_ResponsibleParty">
      <xsl:call-template name="render-block-as-row-with-header">
        <xsl:with-param name="header" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
        <xsl:with-param name="block">
          <xsl:apply-templates mode="render-content" select="."/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <!-- Generic templates -->
  <xsl:template mode="render-content" match="gmd:date">
    <xsl:apply-templates mode="render-content" select="gmd:CI_Date/gmd:date"/>
    <xsl:apply-templates mode="render-content" select="gmd:CI_Date/gmd:dateType/gmd:CI_DateTypeCode"/>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:CharacterString]">
    <xsl:variable name="context">
      <xsl:choose>
        <xsl:when test="name()='gmd:title'">
          <xsl:value-of select="name(../..)"/></xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="name(..)"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), $context)"/>
      <xsl:with-param name="value" select="gco:CharacterString/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:parentIdentifier" priority="1000">
    <xsl:variable name="identifier" select="normalize-space(gco:CharacterString)"/>
    <xsl:if test="$identifier!=''">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
        <xsl:with-param name="content">
          <a href="{concat('#/metadata/',$identifier)}">
            <xsl:value-of select="gn-fn-render:getMetadataTitle($identifier, $langId)"/>
          </a>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="render-content" match="@uuidref|srv:identifier" priority="1000">
    <xsl:variable name="identifier" select="normalize-space(.)"/>
    <xsl:if test="$identifier!=''">
      <xsl:variable name="title">
        <xsl:choose>
          <xsl:when test="name()='srv:identifier'"><xsl:value-of select="gn-fn-render:getMetadataTitleByDatasetIdentifier($identifier, $langId)"/></xsl:when>
          <xsl:when test="name()='uuidref' and name(..)='srv:operatesOn'"><xsl:value-of select="gn-fn-render:getMetadataTitleByDatasetIdentifier($identifier, $langId)"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="gn-fn-render:getMetadataTitle($identifier, $langId)"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="$title!=$identifier">
        <xsl:call-template name="render-row">
          <xsl:with-param name="label">
            <xsl:choose>
              <xsl:when test="name()='srv:identifier'">{{'coupledResourceName' | translate}}</xsl:when>
              <xsl:when test="name()='uuidref' and name(..)='srv:operatesOn'">{{'operatesOnName' | translate}}</xsl:when>
              <xsl:otherwise>{{'objCatName' | translate}}</xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
          <xsl:with-param name="content">
            <xsl:variable name="fileIdentifier">
              <xsl:choose>
                <xsl:when test="name()='uuidref' and name(..)='srv:operatesOn'">
                  <xsl:call-template name="get-param-value-from-url">
                    <xsl:with-param name="url" select="../@xlink:href"/>
                    <xsl:with-param name="param" select="'id'" />
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="$identifier"/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <a href="{concat('#/metadata/',$fileIdentifier)}">
              <xsl:value-of select="$title"/>
            </a>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
        <xsl:with-param name="content" select="$identifier"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="render-content" match="gml:identifier|gco:Record|gco:LocalName|gco:ScopedName">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Integer]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value" select="gco:Integer/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Boolean]">
    <xsl:call-template name="render-text-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="gco:Boolean = 'true'">
            <xsl:value-of select="$schemaStrings/trueValue"/>
          </xsl:when>
          <xsl:when test="gco:Boolean = 'false'">
            <xsl:value-of select="$schemaStrings/falseValue"/>
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gmx:Anchor]">
    <xsl:variable name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
    <xsl:variable name="link" select="normalize-space(gmx:Anchor/@xlink:href)"/>
    <xsl:variable name="value" select="normalize-space(gmx:Anchor/text())"/>
    <xsl:if test="not($link)">
      <xsl:message select="concat('Render text', $value)" />
      <xsl:call-template name="render-text-as-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="value" select="$value"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="$link!=''">
      <xsl:call-template name="render-anchor-as-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="link" select="$link"/>
        <xsl:with-param name="value" select="$value"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gco:Date|gco:DateTime]">
    <xsl:call-template name="render-date-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="date" select="gco:Date/text()|gco:DateTime/text()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="*[@codeListValue]">
    <xsl:if test="normalize-space(@codeListValue)">
      <xsl:variable name="context">
        <xsl:choose>
          <xsl:when test="name(../..)='gmd:MD_Metadata'">
            <xsl:value-of select="concat('/',name(../..),'/',name(..))"/></xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="name(../..)"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:call-template name="render-codelist-as-row">
        <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(..), $context)"/>
        <xsl:with-param name="codelist" select="@codeListValue"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template mode="render-content" match="*[gmd:URL]">
    <xsl:call-template name="render-url-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="url" select="gmd:URL"/>
    </xsl:call-template>
  </xsl:template>


  <!-- More specific Templates -->
  <xsl:template mode="render-content" match="gmd:electronicMailAddress[gco:CharacterString|gmx:Anchor]">
    <xsl:call-template name="render-url-as-row">
      <xsl:with-param name="label" select="tr:nodeLabel($schemaLoc, name(), name(..))"/>
      <xsl:with-param name="url" select="gco:CharacterString|gmx:Anchor"/>
      <xsl:with-param name="prefix" select="'mailto:'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:keyword[gco:CharacterString|gmx:Anchor]">
    <xsl:variable name="link" select="normalize-space(gmx:Anchor/@xlink:href)"/>
    <xsl:variable name="value" select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
    <xsl:variable name="toolTip" select="concat('{{''clickToFilterOn'' | translate}} ', $value)"/>
    <span class="gp-keyword">
      <xsl:if test="$link='' and $value!=''">
        <xsl:value-of select="$value"/>
      </xsl:if>
      <xsl:if test="$link!=''">
        <a>
          <xsl:attribute name="href" select="$link"/>
          <xsl:attribute name="target" select="'_blank'"/>
          <xsl:value-of select="$value"/>
        </a>
      </xsl:if>
      <a>
        <xsl:attribute name="href" select="''"/>
        <xsl:attribute name="title" select="$toolTip"/>
        <xsl:attribute name="aria-label" select="$toolTip"/>
        <xsl:attribute name="data-ng-click"
                       select="concat('search({''keyword'':''', replace($value, '''', '\\'''), '''})')"/>
        <i class="fa fa-search"/>
      </a>
    </span>
  </xsl:template>

  <xsl:template mode="render-content" match="gmd:keyword[../gmd:thesaurusName/gmd:CI_Citation/gmd:title/*[normalize-space() = ('gemet - inspire themes, version 1.0','GEMET - INSPIRE thema''s, versie 1.0')]]" priority="1000">
    <xsl:variable name="value" select="normalize-space(gco:CharacterString|gmx:Anchor)"/>
    <xsl:variable name="inspireThemeAcronym">
      <xsl:call-template name="getInspireThemeAcronym">
        <xsl:with-param name="keyword" select="$value"/>
      </xsl:call-template>
    </xsl:variable>
    <button class="{concat('btn btn-sm btn-default ',$inspireThemeAcronym,' ',$inspireThemeAcronym,'-{{langs[lang]}}')}">
      <xsl:attribute name="data-ng-click" select="concat('search({''inspirethemewithac'':''',$inspireThemeAcronym, '|', $value,'''})')"/>
      <xsl:attribute name="title" select="concat('{{''clickToFilterOn'' | translate}} {{''',$value,''' | translate}}')"/>
      <span class="{concat('iti-',$inspireThemeAcronym)}"></span> <xsl:value-of select="$value" />
    </button>
  </xsl:template>

  <!-- =============================================  -->
  <!-- Formatter templates                            -->
  <!-- Utility templates to format content before     -->
  <!-- displaying it                                  -->
  <!-- =============================================  -->
  <xsl:template name="render-text-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="value"/>
    <xsl:if test="normalize-space($value)">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content" select="$value"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-date-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="date" />
    <xsl:if test="normalize-space($date)">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content">
          <span data-gn-humanize-time="{.}">
            <xsl:attribute name="data-format">
              <xsl:choose>
                <xsl:when test="matches($date, '[0-9]{4}-[0-9]{2}-[0-9]{2}')">DD/MM/YYYY</xsl:when>
                <xsl:when test="matches($date, '[0-9]{4}-[0-9]{2}')">MMM YYYY</xsl:when>
                <xsl:when test="matches($date, '[0-9]{4}')">YYYY</xsl:when>
                <xsl:otherwise/>
              </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
          </span>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-codelist-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="codelist" as="node()"/>
    <xsl:variable name="codelistLabel" select="tr:codelist-value-label($schemaLoc, local-name($codelist/..), $codelist)"/>
    <xsl:variable name="codelistDesc" select="tr:codelist-value-desc($schemaLoc, local-name($codelist/..), $codelist)"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content">
        <xsl:if test="$codelistDesc">
          <strong>
            <xsl:value-of select="concat($codelistLabel, ': ')"/>
          </strong>
          <xsl:value-of select="$codelistDesc"/>
        </xsl:if>
        <xsl:if test="not($codelistDesc)">
          <xsl:value-of select="$codelistLabel"/>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="render-block-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="block" as="node()"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content">
        <xsl:call-template name="render-block">
          <xsl:with-param name="block" select="$block"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="render-block-as-row-with-header">
    <xsl:param name="header" as="xs:string"/>
    <xsl:param name="block" as="node()"/>
    <xsl:if test="normalize-space($block)">
      <xsl:call-template name="render-row-with-colspan">
        <xsl:with-param name="header" select="$header"/>
        <xsl:with-param name="content">
          <xsl:call-template name="render-block">
            <xsl:with-param name="block" select="$block"/>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-url-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="url" as="xs:string"/>
    <xsl:param name="prefix" as="xs:string" select="''"/>
    <xsl:if test="$url!=''">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content">
          <a class="gn-break" href="{concat($prefix, $url)}" target="_blank">
            <xsl:value-of select="$url"/>
          </a>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-anchor-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="link" as="xs:string"/>
    <xsl:param name="value" as="xs:string"/>
    <xsl:call-template name="render-row">
      <xsl:with-param name="label" select="$label"/>
      <xsl:with-param name="content">
        <a href="{$link}" target="_blank">
          <xsl:value-of select="$value"/>
        </a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="render-button-as-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="button"/>
    <xsl:if test="normalize-space($button)">
      <xsl:call-template name="render-row">
        <xsl:with-param name="label" select="$label"/>
        <xsl:with-param name="content" select="$button"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- =============================================  -->
  <!-- Renderer templates                             -->
  <!-- Responsible for the layout                     -->
  <!-- =============================================  -->
  <xsl:template name="render-tab">
    <xsl:param name="tabId" as="xs:string"/>
    <xsl:param name="content"/>
    <xsl:if test="normalize-space($content)">
      <div class="tab-pane">
        <xsl:attribute name="id" select="$tabId"/>
        <xsl:copy-of select="$content"/>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-block">
    <xsl:param name="header" required="no"/>
    <xsl:param name="block" as="node()"/>
    <xsl:if test="normalize-space($block)">
      <xsl:if test="$header">
        <h3 class="view-header gp-header"><xsl:value-of select="$header"/></h3>
      </xsl:if>
      <table class="table table-striped">
        <tbody>
          <xsl:copy-of select="$block"/>
        </tbody>
      </table>
    </xsl:if>
  </xsl:template>

  <xsl:template name="render-row">
    <xsl:param name="label" as="xs:string"/>
    <xsl:param name="content"/>
    <tr>
      <th>
        <xsl:if test="name(.)='gmd:denominator'"><xsl:attribute name="style">white-space: nowrap;</xsl:attribute></xsl:if>
        <xsl:value-of select="$label"/>
      </th>
      <td>
        <xsl:copy-of select="$content"/>
      </td>
    </tr>
  </xsl:template>

  <xsl:template name="render-row-with-colspan">
    <xsl:param name="header" as="xs:string"/>
    <xsl:param name="content"/>
    <tr>
      <td colspan="2" class="gp-nest-row">
        <h3 class="view-header gp-header"><xsl:value-of select="$header"/></h3>
        <xsl:copy-of select="$content"/>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>
