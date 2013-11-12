angular.module('TorSearch').controller('PaymentsCtrl',
['$scope', '$window','railsResourceFactory', 'searchResourceFactory', '$route',
($scope, $window, railsResourceFactory, searchResourceFactory, $route) ->
  $scope.active = $route.current.$$route.controller
  Payment = railsResourceFactory({url: '/api/payment', name: 'payment'})
  # Configure search to use the basic CRUD Service
  searchResource = searchResourceFactory($scope, Payment)
  $scope.searchParameters.sort = {key: 'created_at', direction: 'desc'}
  #$scope.searchParameters.search.approved = false
  # Start with a search
  $scope.notice = ""
  $scope.error = ""
  searchResource.search()

  $scope.refresh = () ->
    searchResource.search()

  $scope.apply_coupon = (code) ->
    new Payment({coupon_code: code}).create().then (result) ->
      if result.error?
        $scope.notice = ""
        $scope.error = result.error
      else
        $scope.error = ""
        $scope.notice = "Successfully credited #{result.value} to your account!"
        $scope.refresh()
      console.log code
      console.log result
])