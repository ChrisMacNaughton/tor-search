angular.module('TorSearchAdmin').controller('CommonSearchCtrl', ['$scope', '$window','CommonCRUDService', 'searchResourceFactory', ($scope, $window, $crudService, searchResourceFactory) ->

  # Used for links
  $scope.base_url = $window.location.pathname

  $scope.deleteRecord = (record) ->
    if record.id? and confirm("Are you sure you want to delete #{record.name} [#{record.id}]")
      new $crudService({id:record.id}).delete().then (result) =>
        $scope.$emit 'deletedRecord', {record: record, result: result}

  $scope.$on 'deletedRecord', () ->
    searchResource.search()

  # Configure search to use the basic CRUD Service
  searchResource = searchResourceFactory($scope, $crudService)

  # Start with a search
  searchResource.search()
])