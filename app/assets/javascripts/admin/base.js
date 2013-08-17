function IndexSearchesRealtimeCtrl($scope, $http) {
  $scope.searches = [];

  $scope.realtimeStatus = "Connecting...";
  $scope.channel = "searches";
  $scope.limit = 20;

  PUBNUB.subscribe({
    channel    : $scope.channel,
    restore    : false,

    callback   : function(message) {
      //toggle the progress_bar
      $('#progress_bar').show();

      $scope.$apply(function(){
        $scope.searches.unshift(message);
      });
      $('#progress_bar').hide();
    },

    disconnect : function() {
      $scope.$apply(function(){
        $scope.realtimeStatus = 'Disconnected';
      });
    },

    reconnect  : function() {
      $scope.$apply(function(){
        $scope.realtimeStatus = 'Connected';
      });
    },

    connect  : function() {
      $scope.$apply(function(){
        $scope.realtimeStatus = 'Connected';
        //hide the progress bar
        $('#progress_bar').hide();
      });
    }
})
}
IndexSearchesRealtimeCtrl.$inject = ['$scope', '$http'];