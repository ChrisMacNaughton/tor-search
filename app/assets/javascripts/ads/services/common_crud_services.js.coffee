angular.module('TorSearch').factory('CommonCRUDService', ['railsResourceFactory', '$window',
  (railsResourceFactory, $window) ->
    railsResourceFactory({url: $window.location.pathname})
]);