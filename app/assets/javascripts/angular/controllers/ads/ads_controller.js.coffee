angular.module('TorSearch').controller('AdsCtrl',
['$scope', '$window','railsResourceFactory', 'searchResourceFactory', '$route', '$location'
($scope, $window, railsResourceFactory, searchResourceFactory, $route, $location) ->
  $scope.active = $route.current.$$route.controller
  Ad = railsResourceFactory({url: '/api/ad', name: 'ad'})
  $scope.unauthorized = $location.search()['unauthorized']

  $scope.advertiser_balance = railsResourceFactory({url: '/api/advertiser_balance'}).get()
  # Configure search to use the basic CRUD Service
  searchResource = searchResourceFactory($scope, Ad)
  $scope.searchParameters.sort = {key: 'created_at', direction: 'desc'}
  #$scope.searchParameters.search.approved = false
  # Start with a search
  searchResource.search()

  $scope.refresh = () ->
    searchResource.search()

  $scope.toggle = (record) ->
    active = !record.disabled
    record.disabled = active
    new Ad({id: record.id, disabled: active}).save().then (rec) ->
      $scope.refresh()
])