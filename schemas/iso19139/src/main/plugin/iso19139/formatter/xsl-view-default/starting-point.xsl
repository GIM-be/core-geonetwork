<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:saxon="http://saxon.sf.net/"
                version="2.0">

  <xsl:output method="html"/>

  <xsl:param name="root" select="'html'"/>
  <xsl:param name="withJsonLd" select="'true'"/>
  <xsl:param name="related" select="'onlines'"/>
  <xsl:param name="template" select="''"/>
  <xsl:param name="sideRelated"
             select="'parent|children|services|datasets|hassources|sources|fcats|siblings|associated'"/>

  <xsl:include href="../../formatter/jsonld/iso19139-to-jsonld.xsl"/>
  <xsl:include href="common/render-html.xsl"/>

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="$root = 'div'">
        <!-- Render only a DIV with the record details -->
        <xsl:call-template name="render-record"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Render complete HTML page -->
        <xsl:call-template name="render-html">
          <xsl:with-param name="content">
            <xsl:call-template name="render-record"/>
          </xsl:with-param>
          <xsl:with-param name="title">
            <xsl:apply-templates mode="getMetadataTitle" select="$metadata"/>
          </xsl:with-param>
          <xsl:with-param name="description">
            <xsl:apply-templates mode="getMetadataAbstract" select="$metadata"/>
          </xsl:with-param>
          <xsl:with-param name="type">
            <xsl:apply-templates mode="getMetadataHierarchyLevel" select="$metadata"/>
          </xsl:with-param>
          <xsl:with-param name="thumbnail">
            <xsl:apply-templates mode="getMetadataThumbnail" select="$metadata"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="render-record">
    <div class="container-fluid gn-metadata-view gn-schema-{$schema}">
      <xsl:variable name="type">
        <xsl:apply-templates mode="getMetadataHierarchyLevel" select="$metadata"/>
      </xsl:variable>
      <xsl:variable name="title">
        <xsl:apply-templates mode="getMetadataTitle" select="$metadata"/>
      </xsl:variable>
      <article id="{$metadataUuid}"
               class="gn-md-view gn-metadata-display">
        <div class="row">
          <div class="col-md-8">
            <header>
              <h1>
                <i class="fa gn-icon-{$type}">
                  <xsl:comment select="'icon'"/>
                </i>
                <xsl:value-of select="$title"/>
              </h1>
              <xsl:apply-templates mode="getMetadataHeader" select="$metadata"/>
              <xsl:if test="$related != ''">
                <div gn-related="md"
                     data-user="user"
                     data-types="{$related}">
                  <xsl:comment select="'icon'"/>
                </div>
              </xsl:if>
            </header>
            <div class="aiv-gp-view">
              <!-- Templates defined in the file view.xsl -->
              <xsl:apply-templates mode="render-content" select="/root/gmd:MD_Metadata"/>
            </div>
          </div>
          <div class="gn-md-side gn-md-side-advanced col-md-4">
            <xsl:call-template name="render-sidebar">
              <xsl:with-param name="metadata" select="$metadata"/>
            </xsl:call-template>
          </div>
        </div>
      </article>
      <br/>
      <br/>
    </div>
  </xsl:template>





  <xsl:template name="render-sidebar">
    <xsl:param name="metadata"/>

    <xsl:apply-templates mode="getOverviews" select="$metadata"/>

    <section class="gn-md-side-extent" data-ng-if="mdView.current.record.geoBox.length > 0">
      <h2>
        <i class="fa fa-fw fa-map-marker"></i>
        <span data-translate="">extent</span>
      </h2>
      <p data-ng-if="mdView.current.record.geoDesc">
        <ul>
          <li data-ng-repeat="d in mdView.current.record.geoDesc">{{d}}</li>
        </ul>
      </p>
      <!-- TODO: use map config -->
      <p data-ng-repeat="bbox in mdView.current.record.geoBox">
        <img class="gn-img-thumbnail img-thumbnail gn-img-extent"
             alt="{{{{'extent' | translate}}}}"
             aria-label="{{{{'extent' | translate}}}}"
             data-ng-src="{{{{gnUrl}}}}{{{{lang}}}}/region.getmap.png?mapsrs=EPSG:3857&amp;width=250&amp;background=settings&amp;geomsrs=EPSG:4326&amp;geom={{{{mdView.current.record.getBoxAsPolygon($index)}}}}"/>
      </p>
    </section>

    <section class="gn-md-side-dates"
             data-ng-if="mdView.current.record.creationDate ||
                              mdView.current.record.publicationDate ||
                              mdView.current.record.revisionDate ||
                              mdView.current.record.tempExtentBegin ||
                              mdView.current.record.tempExtentEnd">
      <h2>
        <i class="fa fa-fw fa-clock-o"></i>
        <span data-translate="">tempExtent</span>
      </h2>

      <p>
        <dl data-ng-show="mdView.current.record.creationDate.length > 0">
          <xsl:element name="dt">
            <xsl:attribute name="data-translate"/>
            creationDate
          </xsl:element>
          <dd data-ng-repeat="creaDate in mdView.current.record.creationDate track by $index"
              data-gn-humanize-time="{{{{creaDate}}}}"
              data-format="YYYY-MM-DD"/>
        </dl>
        <dl data-ng-show="mdView.current.record.publicationDate.length > 0">
          <xsl:element name="dt">
            <xsl:attribute name="data-translate"/>
            publicationDate
          </xsl:element>
          <dd data-ng-repeat="pubDate in mdView.current.record.publicationDate track by $index"
              data-gn-humanize-time="{{{{pubDate}}}}"
              data-format="YYYY-MM-DD"/>
        </dl>
        <dl data-ng-show="mdView.current.record.revisionDate.length > 0">
          <xsl:element name="dt">
            <xsl:attribute name="data-translate"/>
            revisionDate
          </xsl:element>
          <dd data-ng-repeat="revDate in mdView.current.record.revisionDate track by $index"
              data-gn-humanize-time="{{{{revDate}}}}"
              data-format="YYYY-MM-DD"/>
        </dl>
        <dl
          data-ng-show="mdView.current.record.tempExtentBegin ||
                                mdView.current.record.tempExtentEnd">
          <xsl:element name="dt">
            <xsl:attribute name="data-translate"/>
            tempExtentBegin
          </xsl:element>
          <dd>
            <span data-gn-humanize-time="{{{{mdView.current.record.tempExtentBegin}}}}" data-format="YYYY-MM-DD"/>
            <i class="fa fa-fw fa-forward"></i>
            <span data-gn-humanize-time="{{{{mdView.current.record.tempExtentEnd}}}}" data-format="YYYY-MM-DD"/>
          </dd>
        </dl>
      </p>
    </section>

    <xsl:if test="$sideRelated != ''">
      <section class="gn-md-side-associated">
        <h2>
          <i class="fa fa-fw fa-link">
            <xsl:comment select="'icon'"/>
          </i>
          <span>
            <xsl:value-of select="$schemaStrings/associatedResources"/>
          </span>
        </h2>
        <div gn-related="md"
             data-user="user"
             data-types="{$sideRelated}">
          Not available
        </div>
      </section>
    </xsl:if>
  </xsl:template>


  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="gmd:MD_Metadata">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


  <xsl:template mode="getMetadataAbstract" match="gmd:MD_Metadata">
    <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
      <xsl:call-template name="localised">
        <xsl:with-param name="langId" select="$langId"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


  <xsl:template mode="getMetadataHierarchyLevel" match="gmd:MD_Metadata">
    <xsl:value-of select="gmd:hierarchyLevel/gmd:MD_ScopeCode/@codeListValue"/>
  </xsl:template>


  <xsl:template mode="getMetadataThumbnail" match="gmd:MD_Metadata">
    <xsl:value-of
      select="gmd:identificationInfo/*/gmd:graphicOverview[1]/gmd:MD_BrowseGraphic/gmd:fileName/gco:CharacterString"/>
  </xsl:template>


  <xsl:template mode="getOverviews" match="gmd:MD_Metadata">
    <section class="gn-md-side-overview">
      <h4>
        <i class="fa fa-fw fa-image">
          <xsl:comment select="'image'"/>
        </i>
        <span>
          <xsl:comment select="name()"/>
          <xsl:value-of select="$schemaStrings/overviews"/>
        </span>
      </h4>
      <xsl:for-each select="gmd:identificationInfo/*/gmd:graphicOverview/*">
        <img data-gn-img-modal="md"
             class="gn-img-thumbnail center-block"
             alt="{$schemaStrings/overview}"
             src="{gmd:fileName/*}"/>
        <xsl:for-each select="gmd:fileDescription">
          <div class="gn-img-thumbnail-caption">
            <xsl:call-template name="localised">
              <xsl:with-param name="langId" select="$langId"/>
            </xsl:call-template>
          </div>
        </xsl:for-each>
      </xsl:for-each>
    </section>
  </xsl:template>


  <xsl:template mode="getMetadataHeader" match="gmd:MD_Metadata">
    <div class="gn-abstract">
      <xsl:for-each select="gmd:identificationInfo/*/gmd:abstract">
        <xsl:call-template name="localised">
          <xsl:with-param name="langId" select="$langId"/>
        </xsl:call-template>
      </xsl:for-each>
    </div>
    <xsl:if test="$withJsonLd = 'true'">
      <script type="application/ld+json">
        <xsl:apply-templates mode="getJsonLD"
                             select="$metadata"/>
      </script>
    </xsl:if>
    <div data-ng-if="user.isEditorOrMore() &amp;&amp; md.mdStatus&lt;50 &amp;&amp; isMdWorkflowEnable">
      <i
        class="fa gn-aiv-workflow-status-all gn-aiv-workflow-status-{{{{(md.mdStatus==2 || md.mdStatus==3) ? 'unlocked' : 'locked'}}}} gn-aiv-workflow-status-{{{{(md.mdStatus &amp;&amp; md.mdStatus &lt; 7) ? md.mdStatus : 'x'}}}}">
        <span>{{'mdStatusRecord' | translate}}: {{('mdStatus-' + md.mdStatus) | translate}}</span>
      </i>
    </div>
  </xsl:template>


  <xsl:template mode="getMetadataCitation" match="gmd:MD_Metadata">
    <!-- Citation -->
    <table class="table">
      <tr class="active">
        <td>
          <div class="pull-left text-muted">
            <i class="fa fa-quote-left fa-4x">
              <xsl:comment select="'icon'"/>
            </i>
          </div>
        </td>
        <td>
          <em title="{$schemaStrings/citationProposal-help}">
            <xsl:comment select="name()"/>
            <xsl:value-of select="$schemaStrings/citationProposal"/>
            <i class="fa fa-info-circle">
              <xsl:comment select="'icon'"/>
            </i>
          </em>
          <br/>
          <p>
            <!-- Custodians -->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact/
                                  *[gmd:role/*/@codeListValue = ('custodian', 'author')]">
              <xsl:variable name="name">
                <xsl:for-each select="gmd:individualName">
                  <xsl:call-template name="localised">
                    <xsl:with-param name="langId" select="$langId"/>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:variable>

              <xsl:value-of select="$name"/>
              <xsl:if test="$name != ''">&#160;(</xsl:if>
              <xsl:for-each select="gmd:organisationName">
                <xsl:call-template name="localised">
                  <xsl:with-param name="langId" select="$langId"/>
                </xsl:call-template>
              </xsl:for-each>
              <xsl:if test="$name">)</xsl:if>
              <xsl:if test="position() != last()">&#160;-&#160;</xsl:if>
            </xsl:for-each>

            <!-- Publication year: use last publication date -->
            <xsl:variable name="publicationDate">
              <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:date/*[
                                gmd:dateType/*/@codeListValue = 'publication']/
                                  gmd:date/gco:*">
                <xsl:sort select="." order="descending"/>

                <xsl:if test="position() = 1">
                  <xsl:value-of select="."/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>

            <xsl:if test="normalize-space($publicationDate) != ''">
              (<xsl:value-of select="substring(normalize-space($publicationDate), 1, 4)"/>)
            </xsl:if>

            <xsl:text>. </xsl:text>

            <!-- Title -->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:citation/*/gmd:title">
              <xsl:call-template name="localised">
                <xsl:with-param name="langId" select="$langId"/>
              </xsl:call-template>
            </xsl:for-each>
            <xsl:text>. </xsl:text>

            <!-- Publishers -->
            <xsl:for-each select="gmd:identificationInfo/*/gmd:pointOfContact/
                              *[gmd:role/*/@codeListValue = 'publisher']/gmd:organisationName">
              <xsl:call-template name="localised">
                <xsl:with-param name="langId" select="$langId"/>
              </xsl:call-template>
              <xsl:if test="position() != last()">&#160;-&#160;</xsl:if>
            </xsl:for-each>

            <!-- Link -->
            <xsl:variable name="url"
                          select="concat($nodeUrl, 'api/records/', $metadataUuid)"/>
            <a href="{url}">
              <xsl:value-of select="$url"/>
            </a>
            <br/>
          </p>
        </td>
      </tr>
    </table>
  </xsl:template>
</xsl:stylesheet>
