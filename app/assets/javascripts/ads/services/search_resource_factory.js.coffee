class SearchParameters
  constructor: () ->
    @totalPages = 1
    @currentPage = 1
    @perPage = 25

    @sort = {
      key: '',
      direction: 'asc'
    }
    @search = {
      term: ''
    }
    @loading     = false

  toParams: () =>
    p = {
      page:     @currentPage
      per_page: @perPage
    }
    angular.forEach @sort, (v,k) ->
      p["sort[#{k}]"] = v
    angular.forEach @search, (v,k) ->
      p["search[advanced][#{k}]"] = v
    p


  toQueryString: () ->
    params=@toParams()
    s=Object.keys(params).reduce((a, k) ->
      a.push k + "=" + encodeURIComponent(params[k])
      a
    , []).join "&"
    s

  receiveResults: (result) ->
    @loading     = false
    @records     = result.records
    @currentPage = result.currentPage
    @totalPages  = result.totalPages
    @totalEntries = result.totalEntries
    @lastResult = result

class SearchResource
  constructor: (@scope, @queryResource) ->
    @_initScopeVariables()

  _initScopeVariables: () ->
    @scope.searchParameters = new SearchParameters()
    @scope.searchOnFirst = @searchOnFirst
    @scope.search = @search
    @scope.sortBy = @sortBy
    $scope = @scope
    @scope.$watch('searchParameters.currentPage', (newVal, oldVal) ->
      unless newVal is oldVal
        $scope.search()
    )
    @scope.$watch('searchParameters.perPage', (newVal, oldVal) ->
      unless newVal is oldVal
        $scope.search()
    )

  sortBy: (field) =>
    if @scope.searchParameters.sort.key == field
      @scope.searchParameters.sort.direction = if @scope.searchParameters.sort.direction == 'asc'
        'desc'
      else
        'asc'
    else
      @scope.searchParameters.sort.key = field
      @scope.searchParameters.sort.direction = 'asc'
    @scope.searchOnFirst()

  search: () =>
    @scope.searchParameters.loading = true
    @queryResource.query(@scope.searchParameters.toParams()).then (result) =>
      @scope.searchParameters.loading = false
      @scope.$emit('SearchResource::results_received', result)
      @scope.searchParameters.receiveResults(result)

  searchOnFirst: () =>
    @scope.searchParameters.currentPage = 1
    @search()

angular.module('TorSearch').factory('searchResourceFactory', [() ->
  ($scope, $queryResource) ->
    new SearchResource($scope, $queryResource)
])
