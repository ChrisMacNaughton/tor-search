angular.module('TorSearch').controller('EditAdCtrl',
['$scope', '$window','railsResourceFactory', 'searchResourceFactory', '$route', '$location',
($scope, $window, railsResourceFactory, searchResourceFactory, $route, $location) ->
  Ad = railsResourceFactory({url: '/api/ad', name: 'ad'})
  # Configure search to use the basic CRUD Service
  $scope.active = $route.current.$$route.controller

  Ad.get($route.current.params.id).then (result) =>
    $scope.ad = result

  $scope.save = () =>
    if $scope.ad.title && $scope.ad.path && $scope.ad.displayPath
      $scope.ad.save().then (result) ->
        $location.path('/ads/'+result.id)
])