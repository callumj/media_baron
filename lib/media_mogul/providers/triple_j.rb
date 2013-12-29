module MediaMogul
  module Providers
    module TripleJ
      OFFICIAL_URL = "http://www.abc.net.au/triplej"
      J_PLAY = "http://www.jplay.com.au/JSite/SearchPlaylists.aspx"
    end
  end
end

require 'media_mogul/providers/triple_j/show'
require 'media_mogul/providers/triple_j/episode'
require 'media_mogul/providers/triple_j/j_play'
