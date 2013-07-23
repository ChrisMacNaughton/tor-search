angular.module('TorSearchAdmin').factory('CommonCRUDService', ['railsResourceFactory', '$window',
  (railsResourceFactory, $window) ->
    railsResourceFactory({url: $window.location.pathname})

]);