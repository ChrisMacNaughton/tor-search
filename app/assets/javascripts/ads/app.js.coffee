angular.module('TorSearch', ['rails']).config ['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
  $locationProvider.html5Mode true
  $routeProvider.when('/ads',
    templateUrl: '/partials/ads/index',
    controller: 'AdsCtrl'
  ).when('/ads/new',
    templateUrl: '/partials/ads/new',
    controller: 'NewAdCtrl'
  ).when('/ads/bitcoin-addresses',
    templateUrl: '/partials/ads/bitcoin_addresses',
    controller: 'BitcoinAddressCtrl'
  ).when('/ads/:id',
    templateUrl: '/partials/ads/edit',
    controller: 'EditAdCtrl'
  )
]