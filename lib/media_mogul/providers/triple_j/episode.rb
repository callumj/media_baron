require 'nokogiri'
require 'addressable/uri'

module MediaMogul
  module Providers
    module TripleJ
      class Episode < MediaMogul::Models::Show

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