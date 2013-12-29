require 'nokogiri'
require 'addressable/uri'

module MediaBaron
  module Providers
    module TripleJ
      class Episode < MediaBaron::Models::Show

        def listing
          if address.match(/SearchPlaylists.aspx/)
            inst = JPlay.new
            split = address.split("#")
            inst.listing split[0], split[1]
          else
            []
          end
        end

      end
    end
  end
end