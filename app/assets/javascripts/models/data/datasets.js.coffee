#= require models/data/xhr_model
#= require models/data/dataset
#= require models/data/dataset_facets

ns = @edsc.models.data

ns.Datasets = do (ko
                  extend=$.extend
                  XhrModel=ns.XhrModel
                  Dataset=ns.Dataset
                  DatasetFacetsModel = ns.DatasetFacets
                  ) ->

  class DatasetsModel extends XhrModel
    @forIds: (ids, query, callback) ->
      datasets = (Dataset.findOrCreate({id: id}, query) for id in ids)
      needsLoad = (dataset.id for dataset in datasets when !dataset.hasAtomData())

      if needsLoad.length > 0
        new DatasetsModel(query).search {echo_collection_id: needsLoad}, (results) =>
          result.dispose() for result in results
          callback(datasets)
      else
        callback(datasets)
      null


    constructor: (query) ->
      super('/datasets.json', query)

      @facets = new DatasetFacetsModel(query)

      # The index where featured datasets stop and un-featured begin
      @_featuredSplitIndex = @computed(read: @_computeFeaturedSplitIndex, deferEvaluation: true, owner: this)
      @featured = @computed(read: @_computeFeatured, deferEvaluation: true, owner: this)
      @unfeatured = @computed(read: @_computeUnfeatured, deferEvaluation: true, owner: this)

    params: ->
      extend({include_facets: true}, super())

    _decorateNextPage: (params, results) ->
      @page++
      if @page > 1
        delete params.include_facets
      params.page_size = 20
      params.page_num = @page

    _toResults: (data, current, params) ->
      query = @query
      entries = data.feed.entry
      newItems = (Dataset.findOrCreate(entry, query) for entry in entries)

      if params.page_num > 1
        current.concat(newItems)
      else
        dataset.dispose() for dataset in current
        @facets.update(data.feed.facets || [])
        newItems

    toggleVisibleDataset: (dataset) =>
      dataset.visible(!dataset.visible())

    _computeFeaturedSplitIndex: ->
      results = @results()
      return 0 if results.length > 0 && !results[0].hasAtomData()
      for ds, i in results
        return i if !ds.hasAtomData() || !ds.featured
      results.length

    _computeFeatured: ->
      @results().slice(0, @_featuredSplitIndex())

    _computeUnfeatured: ->
      @results().slice(@_featuredSplitIndex())

  exports = DatasetsModel
