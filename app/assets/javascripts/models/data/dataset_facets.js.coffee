#= require models/data/xhr_model

ns = @edsc.models.data

ns.DatasetFacets = do (ko) ->

  class Facet
    constructor: (@parent, item) ->
      @term = item.term
      @count = ko.observable(item.count)

      param = @parent.param
      @isSelected = ko.computed =>
        term = @term
        for facet in @parent.queryModel.facets()
          return true if facet.term == term && facet.param == param
        return false

  class FacetsListModel
    constructor: (@queryModel, item) ->
      @name = item.name
      @class_name = ko.computed => @name.toLowerCase().replace(' ', '-')
      @param = item.param
      @opened = ko.observable(false)
      @closed = ko.computed => !@opened()

      values = (new Facet(this, value) for value in item.values)

      @values = ko.observable(values)
      @selectedValues = ko.computed(@_loadSelectedValues)

    setValues: (newValues) =>
      facetsByTerm = {}
      for facet in @values()
        facetsByTerm[facet.term] = facet
      values = []
      for newFacet in newValues
        oldFacet = facetsByTerm[newFacet.term]
        if oldFacet?
          value = oldFacet
          value.count(newFacet.count)
        else
          value = new Facet(this, newFacet)
        values.push(value)
      @values(values)


    _loadSelectedValues: =>
      facet for facet in @values() when facet.isSelected()

    toggleList: =>
      @opened(!@opened())

  class DatasetFacetsModel
    constructor: (query) ->
      @query = query
      @isRelevant = ko.observable(false)
      @appliedFacets = ko.computed(@_computeAppliedFacets, this, deferEvaluation: true)
      @results = ko.observable([])

    _computeAppliedFacets: ->
      result for result in @results() when result.selectedValues().length > 0

    update: (data) ->
      current = @results.peek()
      for item in data
        found = ko.utils.arrayFirst current, (result) ->
          result.name == item.name
        if found
          values = item.values
          value.parent = found for value in item.values
          found.setValues(item.values)
        else
          current.push(new FacetsListModel(@query, item))

      @results(current)
      current

    removeFacet: (facet) =>
      term = facet.term
      param = facet.parent.param
      @query.facets.remove (queryFacet) ->
        queryFacet.term == term && queryFacet.param == param

    addFacet: (facet) =>
      @query.facets([]) unless @query.facets()?
      @query.facets.push(term: facet.term, param: facet.parent.param)

    toggleFacet: (facet) =>
      if facet.isSelected()
        @removeFacet(facet)
      else
        @addFacet(facet)

  exports = DatasetFacetsModel
