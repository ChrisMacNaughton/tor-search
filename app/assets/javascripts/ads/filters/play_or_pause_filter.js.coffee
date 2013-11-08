angular.module('TorSearch').filter 'play_or_pause', () ->
  (input, yes_str, no_str) ->
    if input || input == 'true'
      if yes_str?
        yes_str
      else
        'icon-play'
    else
      if no_str?
        no_str
      else
        'icon-pause'