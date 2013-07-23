class SearchParameters
  constructor: () ->
    @totalPages = 1
    @currentPage = 1
    @perPage = 10

    @sort = {
      key: '',
      direction: 'asc'
    }
    @search = {
      term: ''
    }

  toParams: () ->
    p = {
      page:     @currentPage
      per_page: @perPage
    }
    angular.forEach @sort, (v,k) ->
      p["sort[#{k}]"] = v
    angular.forEach @search, (v,k) ->
      p["search[advanced][#{k}]"] = v
    p

  receiveResults: (result) ->
    @records     = result.records
    @currentPage = result.currentPage
    @totalPages  = result.totalPages


class SearchResource
  constructor: (@scope, @queryResource) ->
    @_initScopeVariables()

  _initScopeVariables: () ->
    @scope.searchParameters = new SearchParameters()
    @scope.searchOnFirst = @searchOnFirst
    @scope.search = @search
    @scope.sortBy = @sortBy
    @scope.$watch('searchParameters.currentPage', @search)
    @scope.$watch('searchParameters.perPage', @search)

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
    @queryResource.query(@scope.searchParameters.toParams()).then (result) =>
      @scope.searchParameters.receiveResults(result)

  searchOnFirst: () =>
    @scope.searchParameters.currentPage = 1
    @search()

angular.module('TorSearchAdmin').factory('searchResourceFactory', [() ->
  ($scope, $queryResource) ->
    new SearchResource($scope, $queryResource)
])
