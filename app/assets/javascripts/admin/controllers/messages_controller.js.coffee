angular.module('TorSearchAdmin').controller('MessagesCtrl', ['$scope', '$window','railsResourceFactory', 'searchResourceFactory', ($scope, $window, railsResourceFactory, searchResourceFactory) ->

  Messages = railsResourceFactory({url: '/admin/messages', name: 'message'})

  # Configure search to use the basic CRUD Service
  searchResource = searchResourceFactory($scope, Messages)
  $scope.searchParameters.sort = {key: 'created_at', direction: 'desc'}

  # Start with a search
  searchResource.search()


])