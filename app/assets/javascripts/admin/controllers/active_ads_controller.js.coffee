angular.module('TorSearchAdmin').controller('ActiveAdsCtrl', ['$scope', '$window','railsResourceFactory', 'searchResourceFactory', ($scope, $window, railsResourceFactory, searchResourceFactory) ->

  Ad = railsResourceFactory({url: '/admin/ads', name: 'ad'})

  # Configure search to use the basic CRUD Service
  searchResource = searchResourceFactory($scope, Ad)
  $scope.searchParameters.sort = {key: 'created_at', direction: 'desc'}
  $scope.searchParameters.search.approved = true
  # Start with a search
  searchResource.search()

  $scope.toggleAd = (ad) ->
    ad.approved = !ad.approved
    new Ad({id: ad.id, approved: ad.approved}).update().then (result) ->
      $scope.$emit 'toggledRecord'

  $scope.refresh = () ->
    searchResource.search()
  $scope.$on 'toggledRecord', () ->
    $scope.refresh()
])