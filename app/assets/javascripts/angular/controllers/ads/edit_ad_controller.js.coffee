angular.module('TorSearch').controller('EditAdCtrl',
['$scope', '$window','railsResourceFactory', 'searchResourceFactory', '$route', '$location',
($scope, $window, railsResourceFactory, searchResourceFactory, $route, $location) ->
  Ad = railsResourceFactory({url: '/api/ad', name: 'ad'})
  Keyword = railsResourceFactory({url: "/api/ad/#{$route.current.params.id}/keyword", name: 'keyword'})
  $scope.new_keyword = Keyword.new
  # Configure search to use the basic CRUD Service
  $scope.active = $route.current.$$route.controller
  $scope.refresh = () ->
    Ad.get($route.current.params.id).then (result) ->
      $scope.ad = result
      $scope.new_record = $location.search()['new']

  $scope.create_keyword = (object) =>
    new Keyword(object).create().then (result) =>
      $scope.refresh()

  $scope.update_keyword = (record) =>
    record.editMode = false
    new Keyword(record).save().then (object) ->
      record = object

  $scope.new_keyword = (record) =>
    record.editMode = false
    new Keyword(record).save().then (object) ->
      $scope.refresh()
      $scope.new_keyword = Keyword.new

  $scope.remove_keyword = (record) =>
    if confirm('Are you sure you want to delete this keyword?')
      new Keyword(record).delete()
      $scope.refresh()

  $scope.save = () =>
    if $scope.ad.title && $scope.ad.path && $scope.ad.displayPath
      $scope.ad.save().then (result) ->
        $location.path('/ads/'+result.id)
  $scope.refresh()
])