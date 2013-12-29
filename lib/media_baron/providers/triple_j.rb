module MediaBaron
  module Providers
    module TripleJ
      OFFICIAL_URL    = "http://www.abc.net.au/triplej"
      J_PLAY          = "http://www.jplay.com.au/JSite/SearchPlaylists.aspx"
      RECENTLY_PLAYED = "http://triplejgizmo.abc.net.au/pav/plays/triplej.php"
    end
  end
end

require 'media_baron/providers/triple_j/show'
require 'media_baron/providers/triple_j/episode'
require 'media_baron/providers/triple_j/j_play'
require 'media_baron/providers/triple_j/recently_played'
