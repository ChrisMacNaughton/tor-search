angular.module('TorSearch').controller('EditAdCtrl',
['$scope', '$window','railsResourceFactory', 'searchResourceFactory', '$route',
($scope, $window, railsResourceFactory, searchResourceFactory, $route) ->
  Ad = railsResourceFactory({url: '/ads', name: 'ad'})
  # Configure search to use the basic CRUD Service
  $scope.active = $route.current.$$route.controller
])