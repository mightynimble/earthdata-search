#= require models/data/grid
#= require models/data/query
#= require models/data/datasets
#= require models/data/project
#= require models/data/preferences
#= require models/ui/spatial_type
#= require models/ui/temporal
#= require models/ui/datasets_list
#= require models/ui/project_list
#= require models/ui/granule_timeline
#= require models/ui/state_manager
#= require models/ui/feedback

models = @edsc.models
data = models.data
ui = models.ui

ns = models.page

ns.SearchPage = do (ko
                    setCurrent = ns.setCurrent
                    QueryModel = data.query.DatasetQuery
                    DatasetsModel = data.Datasets
                    ProjectModel = data.Project
                    SpatialTypeModel = ui.SpatialType
                    DatasetsListModel = ui.DatasetsList
                    ProjectListModel = ui.ProjectList
                    GranuleTimelineModel = ui.GranuleTimeline
                    PreferencesModel = data.Preferences
                    FeedbackModel = ui.Feedback
                    StateManager = ui.StateManager) ->
  current = null

  $(document).ready ->
    current.map = map = new window.edsc.map.Map(document.getElementById('map'), 'geo')
    current.ui.granuleTimeline = new GranuleTimelineModel(current.ui.datasetsList, current.ui.projectList)
    $('.master-overlay').masterOverlay()

  class SearchPage
    constructor: ->
      @query = new QueryModel()
      @datasets = new DatasetsModel(@query)
      @project = new ProjectModel(@query)
      @preferences = new PreferencesModel()

      @ui =
        spatialType: new SpatialTypeModel(@query)
        datasetsList: new DatasetsListModel(@query, @datasets, @project)
        projectList: new ProjectListModel(@project, @datasets)
        isLandingPage: ko.observable(null) # Used by modules/landing
        feedback: new FeedbackModel()

      @bindingsLoaded = ko.observable(false)
      @labs = ko.observable(false)

      @spatialError = ko.computed(@_computeSpatialError)

      @datasets.isRelevant(false) # Avoid load until the URL says it's ok

      @workspaceName = ko.observable(null)
      @workspaceNameField = ko.observable(null)

      new StateManager(this).monitor()

    clearFilters: =>
      @query.clearFilters()
      @ui.spatialType.selectNone()

    pluralize: (value, singular, plural) ->
      word = if value == 1 then singular else plural
      "#{value} #{word}"

    _computeSpatialError: =>
      error = @datasets.error()
      if error?
        for e in error
          return e if e? && (e.indexOf('polygon') != -1 ||
                              e.indexOf('box') != -1 ||
                              e.indexOf('point') != -1)
      null

  current = new SearchPage()
  setCurrent(current)

  exports = SearchPage
