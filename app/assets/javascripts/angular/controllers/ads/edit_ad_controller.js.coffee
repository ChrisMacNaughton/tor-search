angular.module('TorSearch').controller('EditAdCtrl',
['$scope', '$window','railsResourceFactory', 'searchResourceFactory', '$route', '$location',
($scope, $window, railsResourceFactory, searchResourceFactory, $route, $location) ->
  Ad = railsResourceFactory({url: '/api/ad', name: 'ad'})
  Keyword = railsResourceFactory({url: "/api/ad/#{$route.current.params.id}/keyword", name: 'keyword'})

  # Configure search to use the basic CRUD Service
  $scope.active = $route.current.$$route.controller

  $scope.refresh = () ->
    Ad.get($route.current.params.id).then (result) ->
      $scope.ad = result

  $scope.remove_keyword = (object) =>
    k = new Keyword(object)
    k.delete().then () ->
      $scope.refresh()
  $scope.create_keyword = (object) =>
    new Keyword(object).create().then (result) =>
      $scope.refresh()

  $scope.save = () =>
    if $scope.ad.title && $scope.ad.path && $scope.ad.displayPath
      $scope.ad.save().then (result) ->
        $location.path('/ads/'+result.id)
  $scope.refresh()
])