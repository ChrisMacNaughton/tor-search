function AdminCtrl($scope, $http) {
  $http.get('admin/searches.json').success(function(data) {
    $scope.searches = data;
  });
}