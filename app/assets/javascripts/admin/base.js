function AdminCtrl($scope, $http) {
  $interval(
    $http.get('admin/searches.json').success(function(data) {
      $scope.searches = data;
    });
  ), 500);
}