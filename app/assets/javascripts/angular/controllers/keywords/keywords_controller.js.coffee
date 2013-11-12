angular.module('TorSearch').controller('KeywordsCtrl',
['$scope', '$window','railsResourceFactory', 'searchResourceFactory', '$route',
($scope, $window, railsResourceFactory, searchResourceFactory, $route) ->
  $scope.active = $route.current.$$route.controller
  Keyword = railsResourceFactory({url: '/api/keyword', name: 'keyword'})
  Ad = railsResourceFactory({url: '/api/ad', name: 'ad'})

  Ad.query().then (result) ->
    $scope.ads = result.records
  # Configure search to use the basic CRUD Service
  searchResource = searchResourceFactory($scope, Keyword)
  $scope.searchParameters.sort = {key: 'created_at', direction: 'desc'}
  #$scope.searchParameters.search.approved = false
  # Start with a search
  searchResource.search()

  $scope.refresh = () =>
    searchResource.search()

  $scope.update = (record) =>
    record.editMode = false
    new Keyword(record).save().then (object) ->
      record = object
  $scope.remove = (record) =>
    if confirm('Are you sure you want to delete this keyword?')
      new Keyword(record).delete()
      $scope.refresh()
  $scope.create_keywords = () =>
    Keyword.$post('/api/keyword',{ad_id: $scope.ad.id, keywords: $scope.keywords}).then () ->
      $scope.add_keywords = false
      $scope.refresh()
  $scope.reset_keywords = () =>
    $scope.add_keywords = false
    $scope.ad = null
    $scope.keywords = null
])