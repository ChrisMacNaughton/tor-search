angular.module('TorSearchAdmin').controller('SearchesCtrl', ['$scope', '$window','railsResourceFactory', 'searchResourceFactory', ($scope, $window, railsResourceFactory, searchResourceFactory) ->

  Searches = railsResourceFactory({url: '/admin/searches', name: 'search'})

  # Configure search to use the basic CRUD Service
  searchResource = searchResourceFactory($scope, Searches)
  $scope.searchParameters.sort = {key: 'created_at', direction: 'desc'}

  # Start with a search
  searchResource.search()
])