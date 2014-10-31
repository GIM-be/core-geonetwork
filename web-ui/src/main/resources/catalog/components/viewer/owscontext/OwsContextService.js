(function() {
  goog.provide('gn_owscontext_service');

  var module = angular.module('gn_owscontext_service', []);

  // OWC Client
  // Jsonix wrapper to read or write OWS Context
  var context =  new Jsonix.Context(
    [XLink_1_0, OWS_1_0_0, Filter_1_0_0, GML_2_1_2, SLD_1_0_0, OWC_0_3_1],
    {
      namespacePrefixes : {
        "http://www.w3.org/1999/xlink": "xlink",
        "http://www.opengis.net/ows": "ows"
      }
    }
  );
  var unmarshaller = context.createUnmarshaller();
  var marshaller = context.createMarshaller();

  module.service('gnOwsContextService', [
    'gnMap',
    'gnOwsCapabilities',
    '$http',
    'gnViewerSettings',
    function(gnMap, gnOwsCapabilities, $http, gnViewerSettings) {

      /**
       * Loads a context, ie. creates layers and centers the map
       * @param context object
       */
      this.loadContext = function(text, map) {
        var context = unmarshaller.unmarshalString(text).value;
        // first remove any existing layer
        var layersToRemove = [];
        map.getLayers().forEach(function(layer) {
          if (layer.displayInLayerManager) {
            layersToRemove.push(layer);
          }
        });
        for (var i = 0; i < layersToRemove.length; i++) {
          map.removeLayer(layersToRemove[i]);
        }

        // set the General.BoundingBox
        var bbox = context.general.boundingBox.value;
        var ll = bbox.lowerCorner;
        var ur = bbox.upperCorner;
        var extent = ll.concat(ur);
        var projection = bbox.crs;
        // reproject in case bbox's projection doesn't match map's projection
        extent = ol.proj.transformExtent(extent, map.getView().getProjection(),
          projection);

        // store the extent into view settings so that it can be used later in
        // case the map is not visible yet
        gnViewerSettings.initialExtent = extent;
        map.getView().fitExtent(extent, map.getSize());

        // load the resources
        var layers = context.resourceList.layer;
        var i, j, olLayer, bgLayers = [];
        var self = this;
        var re = /{.*type\s*=\s*(.*)\s*}/;
        for (i = 0; i < layers.length; i++) {
          var layer = layers[i];
          if (layer.group == 'Background layers' && layer.name.match(re)) {
            var type = re.exec(layer.name)[1];
            var olLayer = gnMap.createLayerForType(type);
            if (olLayer) {
              bgLayers.push(olLayer);
              olLayer.displayInLayerManager = false;
              olLayer.background = true;
              olLayer.set('group', 'Background layers');
              olLayer.setVisible(!layer.hidden);
            }
          } else {
            var server = layer.server[0];
            if (server.service == 'urn:ogc:serviceType:WMS') {
              self.addWmsLayer(layer, map);
            }
          }
        }

        // if there's at least one valid bg layer in the context use them for
        // the application otherwise use the defaults from config
        if (bgLayers.length > 0) {
          // first clear settings bgLayers
          gnViewerSettings.bgLayers.length = 0;
          $.each(bgLayers, function(index, item) {
            gnViewerSettings.bgLayers.push(item);
            if (item.getVisible()) {
              map.getLayers().removeAt(0);
              map.getLayers().insertAt(0, item);
            }
          });
        }
      };

      /**
       * Loads a context from an URL.
       * @param url URL to context
       * @param map map
       */
      this.loadContextFromUrl = function(url, map, useProxy) {
        var self = this;
        if (useProxy) {
          url = '../../proxy?url=' + encodeURIComponent(url);
        }
        $http.get(url).success(function(data) {
          self.loadContext(data, map);
        });
      };

      /**
       * Creates a javascript object based on map context then marshals it
       *    into XML
       * @param context object
       */
      this.writeContext = function(map) {

        var extent = map.getView().calculateExtent(map.getSize());

        var general = {
          boundingBox: {
            name: {
              "namespaceURI": "http://www.opengis.net/ows",
              "localPart": "BoundingBox"
            },
            value: {
              crs: map.getView().getProjection().getCode(),
              lowerCorner: [extent[0], extent[1]],
              upperCorner: [extent[2], extent[3]]
            }
          }
        };

        var resourceList = {
          layer: []
        };

        // add the background layers
        angular.forEach(gnViewerSettings.bgLayers, function(layer) {
          var source = layer.getSource();
          var name;
          if (source instanceof ol.source.OSM) {
            name = "{type=osm}";
          } else if (source instanceof ol.source.MapQuest) {
            name = "{type=mapquest}";
          } else if (source instanceof ol.source.BingMaps) {
            name = "{type=bing_aerial}";
          } else {
            return;
          }
          resourceList.layer.push({
            hidden: map.getLayers().getArray().indexOf(layer) < 0,
            opacity: layer.getOpacity(),
            name: name,
            title: layer.get('title'),
            group: layer.get('group')
          });
        });

        map.getLayers().forEach(function(layer) {
          var source = layer.getSource();
          var url = "";
          var name;

          // background layers already taken into account
          if (layer.background) {
            return;
          }

          if (source instanceof ol.source.ImageWMS) {
            name = source.getParams().LAYERS;
            url = source.getUrl();
          } else if (source instanceof ol.source.TileWMS) {
            name = source.getParams().LAYERS;
            url = source.getUrls()[0];
          }
          resourceList.layer.push({
            hidden: !layer.getVisible(),
            opacity: layer.getOpacity(),
            name: name,
            title: layer.get('title'),
            group: layer.get('group'),
            server: [{
              onlineResource: [{
                href: url
              }],
              service: "urn:ogc:serviceType:WMS"
            }]
          });
        });

        var context = {
          version: "0.3.1",
          id: "ows-context-ex-1-v3",
          general: general,
          resourceList: resourceList
        };

        var xml = marshaller.marshalDocument({
          name: {
            localPart: 'OWSContext',
            namespaceURI: "http://www.opengis.net/ows-context",
            prefix: "ows-context",
            string: "{http://www.opengis.net/ows-context}ows-context:OWSContext"
          },
          value: context
        });
        return xml;
      };

      /**
       * Saves the map context to local storage
       */
      this.saveToLocalStorage = function(map) {
        if (map.getSize()[0] == 0 || map.getSize()[1] == 0){
          // don't save a map which has not been rendered yet
          return;
        }
        var xml = this.writeContext(map);
        var xmlString = (new XMLSerializer()).serializeToString(xml);
        window.localStorage.setItem("owsContext", xmlString);
      };

      /**
       * Adds a WMS layer to map
       * @param layer layer
       * @param map map
       */
      this.addWmsLayer = function(obj, map) {
        var server = obj.server[0];
        var res = server.onlineResource[0];
        gnOwsCapabilities.getCapabilities(res.href).then(function(capObj) {
          var info = gnOwsCapabilities.getLayerInfoFromCap(obj.name, capObj);
          var layer = gnMap.addWmsToMapFromCap(map, info);

          layer.setOpacity(obj.opacity);
          layer.setVisible(!obj.hidden);
          // TODO test this
          layer.set('group', obj.group);
        });
      };
    }
  ]);
})();
