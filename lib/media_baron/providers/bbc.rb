module MediaBaron
  module Providers
    module BBC
      REGEX_PARSE     = /(programmes|episode)\/([A-Za-z0-9]*)\/?/
      RECENTLY_PLAYED = "http://www.bbc.co.uk/radio/stations/$1.mp"
    end
  end
end

require 'media_baron/providers/bbc/show'
require 'media_baron/providers/bbc/episode'
require 'media_baron/providers/bbc/recently_played'