angular.module('TorSearch').controller('BitcoinAddressCtrl',
['$scope', '$window','railsResourceFactory', 'searchResourceFactory', '$route',
($scope, $window, railsResourceFactory, searchResourceFactory, $route) ->
  $scope.active = $route.current.$$route.controller
  Address = railsResourceFactory({url: '/api/bitcoin_address', name: 'address'})
  # Configure search to use the basic CRUD Service
  searchResource = searchResourceFactory($scope, Address)
  $scope.searchParameters.sort = {key: 'created_at', direction: 'desc'}
  #$scope.searchParameters.search.approved = false

  $scope.refresh = () ->
    searchResource.search()

  $scope.new_address = () ->
    new Address({}).create().then (result) ->
      if $scope.searchParameters.currentPage == 1
        $scope.searchParameters.records.unshift(result.records[0])
        $scope.searchParameters.records = $scope.searchParameters.records.splice(0,10)
      else
        $scope.refresh()

  # Start with a search
  $scope.refresh()

])