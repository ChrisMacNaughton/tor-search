angular.module('TorSearchAdmin').directive 'sortable', () -> {
  restrict: 'A'
  link: ($scope, element, attrs) ->
    element.bind "click", (evt) ->
      $scope.sortBy(attrs['sortable'])
      console.log "Clicked!"
      false
}