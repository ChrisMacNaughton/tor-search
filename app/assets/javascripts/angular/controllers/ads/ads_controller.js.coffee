angular.module('TorSearch').controller('AdsCtrl',
['$scope', '$window','railsResourceFactory', 'searchResourceFactory', '$route',
($scope, $window, railsResourceFactory, searchResourceFactory, $route) ->
  $scope.active = $route.current.$$route.controller
  Ad = railsResourceFactory({url: '/api/ad', name: 'ad'})

  # Configure search to use the basic CRUD Service
  searchResource = searchResourceFactory($scope, Ad)
  $scope.searchParameters.sort = {key: 'created_at', direction: 'desc'}
  #$scope.searchParameters.search.approved = false
  # Start with a search
  searchResource.search()

  $scope.refresh = () ->
    searchResource.search()

  $scope.toggle = (record) ->
    record.disabled = !record.disabled
    new Ad({id: record.id, disabled: !record.disabled}).save().then (rec) ->
      $scope.refresh()
])