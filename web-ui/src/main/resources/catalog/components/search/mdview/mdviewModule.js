/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

(function() {
  goog.provide('gn_mdview');




  goog.require('gn_mdview_directive');
  goog.require('gn_mdview_service');
  goog.require('gn_related_observer_directive');
  goog.require('gn_userfeedback');
  goog.require('gn_thesaurus');
  goog.require('gn_catalog_service');

  var module = angular.module('gn_mdview', [
    'gn_mdview_service',
    'gn_mdview_directive',
    'gn_related_observer_directive',
    'gn_userfeedback',
    'gn_thesaurus',
    'gn_catalog_service'
  ]);

  module.controller('GnMdViewController', [
    '$scope', '$http', '$compile', 'gnSearchSettings', 'gnSearchLocation',
    'gnMetadataActions', 'gnAlertService', '$translate', '$location',
    'gnMdView', 'gnMdViewObj', 'gnMdFormatter', 'gnConfig',
    'gnGlobalSettings', 'gnConfigService', '$rootScope', '$timeout',
    function($scope, $http, $compile, gnSearchSettings, gnSearchLocation,
             gnMetadataActions, gnAlertService, $translate, $location,
             gnMdView, gnMdViewObj, gnMdFormatter, gnConfig,
             gnGlobalSettings, gnConfigService, $rootScope, $timeout) {

      $scope.formatter = gnSearchSettings.formatter;
      $scope.gnMetadataActions = gnMetadataActions;
      $scope.url = location.href;
      $scope.compileScope = $scope.$new();
      $scope.recordIdentifierRequested = gnSearchLocation.getUuid();
      $scope.isUserFeedbackEnabled = false;
      $scope.isRatingEnabled = false;
      $scope.isSocialbarEnabled = gnGlobalSettings.gnCfg.mods.recordview.isSocialbarEnabled;

      gnConfigService.load().then(function(c) {
        $scope.isRecordHistoryEnabled = gnConfig['system.metadata.history.enabled'];

        var statusSystemRating =
          gnConfig['system.localrating.enable'];

        if (statusSystemRating == 'advanced') {
          $scope.isUserFeedbackEnabled = true;
        }
        if (statusSystemRating == 'basic') {
          $scope.isRatingEnabled = true;
        }
      });

      $scope.search = function(params) {
        $location.path('/search');
        $location.search(params);
      };
      $scope.deleteRecord = function(md) {
        return gnMetadataActions.deleteMd(md).then(function(data) {
          gnAlertService.addAlert({
            msg: $translate.instant('metadataRemoved',
                {title: md.title || md.defaultTitle}),
            type: 'success'
          });
          $scope.closeRecord(md);
        }, function(reason) {
          // Data needs improvements
          // See https://github.com/geonetwork/core-geonetwork/issues/723
          gnAlertService.addAlert({
            msg: $translate.instant(reason.data.description),
            type: 'danger'
          });
        });
      };

      // activate the tabs in the advanded metadata view
      $scope.activateTabs = function() {

        // attach click to tab
        $('.nav-tabs-advanced a').click(function(e) {
          e.preventDefault();
          $(this).tab('show');
        });
        // hide empty tab
        $('.nav-tabs-advanced a').each(function() {

          var tabLink = $(this).attr('href');

          if (tabLink) {
            if ($(tabLink).length === 0) {
              $(this).parent().hide();
            }
          }
        });

        //Stack tabs in a dropdown if more than 5
        $('.nav-tabs-advanced li:not(#tab-overflow)')
          .filter(':visible')
          .slice(5)
          .each(function() {
            $(this).appendTo('#tab-overflow .dropdown-menu');
            var overflow = $('#tab-overflow');
            if(overflow.is(':hidden')) {
              overflow.show();
            }
          })

        // show the first tab
        $('.nav-tabs-advanced a:first').tab('show');
      };

      $scope.loadFormatter = function(url) {
        if ($scope.mdView.current.record == null) {
          return;
        }
        var gn_metadata_display = $('#gn-metadata-display');
        gn_metadata_display.find('*').remove();
        gnMdViewObj.loadingFormatter = true;

        $http.get(url, {
          headers: {
            Accept: 'text/html'
          },
          params: {
            approved : gnSearchLocation.isApprovedView()
          }
        }).then(
          function(response,status) {
            gnMdViewObj.loadingFormatter = false;
            if (response.status!=200){
              gn_metadata_display.append(
                "<div class='alert alert-danger top-buffer'>" +
                $translate.instant("metadataViewLoadError") +
                "</div>");
            } else {
              var snippet = response.data.replace(
                '<?xml version="1.0" encoding="UTF-8"?>', '');

              $scope.compileScope.$destroy();

              // Compile against a new scope
              $scope.compileScope = $scope.$new();
              var content = $compile(snippet)($scope.compileScope);

              gn_metadata_display.append(content);

              // activate the tabs in the full view
              $scope.activateTabs();
            }
          },
          function(data) {
            gnMdViewObj.loadingFormatter = false;
            gn_metadata_display.append(
              "<div class='alert alert-danger top-buffer'>" +
              $translate.instant("metadataViewLoadError") +
              "</div>");
          });
      };

      // Reset current formatter to open the next record
      // in default mode.
      $scope.currentViewedMD = undefined;
      $scope.currentSchema = undefined;

      function loadFormatter() {
        $scope.currentFormatter = null;
        var f = gnSearchLocation.getFormatterPath($scope.currentSchema);
        if (f != undefined) {
          $scope.currentFormatter = {
            url: f
          };
          $scope.loadFormatter(f);
        }
      }
      // $scope.$watch('mdView.current.record', loadFormatter);

      var featureTypesPromise = undefined

      function checkForViewChanges() {
        if ($scope.mdView.current.record != null) {
          var uuid = gnSearchLocation.getUuid();
          var formatter = gnSearchLocation.getFormatterPath($scope.currentSchema);
          if (uuid !== $scope.currentViewedMD || (formatter && (!$scope.currentFormatter || formatter !== $scope.currentFormatter.url))) {
            $scope.currentViewedMD = uuid;
            $scope.currentSchema = $scope.mdView.current.record['geonet:info'].schema;
            loadFormatter();
          }
          if (featureTypesPromise) {
            featureTypesPromise.cancel();
            featureTypesPromise = undefined;
          }
          if ($scope.mdView.current.record.featureTypes === '#tooLong') {
            populateFeatureTypes();
          }
        }
      }

      function populateFeatureTypes() {
        var uuid = $scope.mdView.current.record['geonet:info'].uuid
        var prom = $http.get('../api/records/' + uuid + '/featureTypes');
        featureTypesPromise = makeCancellablePromise(prom);
        featureTypesPromise.then(function(response) {
          $scope.mdView.current.record.featureTypes = response.data;
        }).catch(function() {
          // Cancelled
        });
      }

      function makeCancellablePromise(promise) {
        var rejectFn;
        var wrappedPromise = new Promise(function(resolve, reject) {
          rejectFn = reject;
          Promise.resolve(promise)
            .then(resolve)
            .catch(reject);
        });
        wrappedPromise.cancel = function() {
          rejectFn({ canceled: true });
        };
        return wrappedPromise;
      }

      $rootScope.$on('$locationChangeSuccess', function() {
        $timeout(function() {
          checkForViewChanges()
        }, 0);
      });

      $scope.$watch('mdView.current.record', checkForViewChanges);

      // Know from what path we come from
      $scope.gnMdViewObj = gnMdViewObj;
      $scope.$watch('gnMdViewObj.from', function(v) {
        $scope.fromView = v ? v.substring(1) : v;
      });

      $scope.isFormatterAllowed = function (formatter) {
        if ($scope.mdView.current.record) {
          if (formatter.include) {
            return formatter.include.includes($scope.currentSchema);
          } else if (formatter.exclude) {
            return !formatter.exclude.includes($scope.currentSchema);
          }
        }
        return true;
      };

      $scope.isCurrentFormatter = function(formatter) {
        return gnSearchLocation.isCurrentFormatter(formatter);
      }

    }]);
})();
