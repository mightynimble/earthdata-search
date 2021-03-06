ns = @edsc.map

# Meta-layer for managing granule visualizations
ns.GranuleVisualizationsLayer = do (L, dateUtil=@edsc.util.date, extend = $.extend, GranuleLayer=ns.L.GranuleLayer, project = @edsc.page.project) ->
  #MIN_PAGE_SIZE = 100

  class GranuleVisualizationsLayer
    constructor: ->
      @_datasetIdsToLayers = {}

    onAdd: (map) ->
      @_map = map
      map.on 'edsc.visibledatasetschange', @_onVisibleDatasetsChange

    onRemove: (map) ->
      @_map = map
      map.off 'edsc.visibledatasetschange', @_onVisibleDatasetsChange

    _onVisibleDatasetsChange: (e) =>
      @setVisibleDatasets(e.datasets)

    setVisibleDatasets: (datasets) =>
      map = @_map

      datasetIdsToLayers = @_datasetIdsToLayers
      newDatasetIdsToLayers = {}

      baseZ = 6
      overlayZ = 16

      for dataset in datasets
        id = dataset.id
        options = dataset.gibs()
        if options?[0].format == 'jpeg'
          z = Math.min(baseZ++, 9)
        else
          z = Math.min(overlayZ++, 19)

        if datasetIdsToLayers[id]?
          layer = datasetIdsToLayers[id]
        else
          color = project.colorForDataset(dataset)
          # Note: our algorithms rely on sort order being [-start_date]
          layer = new GranuleLayer(dataset, color, options)
          map.addLayer(layer)

          if dataset.boxes?.length > 0
            [lat1, lon1, lat2, lon2] = dataset.boxes[0].split(' ').map((item) ->
              parseFloat item)
            southWest = L.latLng(lat1, lon1)
            northEast = L.latLng(lat2, lon2)
            bounds = L.latLngBounds(southWest, northEast);
            if bounds.getNorth() - bounds.getSouth() < .5 && bounds.getWest() - bounds.getEast() < .5
              marker = L.featureGroup().addLayer(L.marker(bounds.getCenter()))
              map.addLayer(marker)
              newDatasetIdsToLayers[id + '-marker'] = marker

        layer.setZIndex(z)
        newDatasetIdsToLayers[id] = layer

      for own id, layer of datasetIdsToLayers
        unless newDatasetIdsToLayers[id]?
          map.removeLayer(layer)
          if newDatasetIdsToLayers[id+'-marker']?
            map.removeLayer(newDatasetIdsToLayers[id+'-marker'])

      @_datasetIdsToLayers = newDatasetIdsToLayers

      null

  exports = GranuleVisualizationsLayer
