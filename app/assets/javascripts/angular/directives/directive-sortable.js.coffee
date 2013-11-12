angular.module('TorSearch').directive 'sortable', () -> {
  restrict: 'A'
  link: ($scope, element, attrs) ->
    element.bind "click", (evt) ->
      $scope.sortBy(attrs['sortable'])
      false
}