require 'nokogiri'
require 'addressable/uri'

module MediaBaron
  module Providers
    module TripleJ
      class Episode < MediaBaron::Models::Show

        def listing
          @listing ||= begin
            if address.match(/SearchPlaylists.aspx/)
              inst = JPlay.new
              split = address.split("#")
              inst.listing split[0], split[1]
            else
              []
            end
          end
        end

        def tracks_played
          listing.map do |item|
            {artist: item[:artist], track: item[:name], time: item[:timing]}
          end
        end

      end
    end
  end
end