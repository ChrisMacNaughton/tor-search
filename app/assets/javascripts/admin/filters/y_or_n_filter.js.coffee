angular.module('TorSearchAdmin').filter 'y_or_n', () ->
  (input, yes_str, no_str) ->
    if input || input == 'true'
      if yes_str?
        yes_str
      else
        'Y'
    else
      if no_str?
        no_str
      else
        'N'