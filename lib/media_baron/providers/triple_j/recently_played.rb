require 'addressable/uri'

module MediaBaron
  module Providers
    module TripleJ
      class RecentlyPlayed

        def initialize
          @parsed = Addressable::URI.parse MediaBaron::Providers::TripleJ::RECENTLY_PLAYED
          @connection = Faraday.new(url: @parsed.origin) do |faraday|
            faraday.request  :url_encoded
            faraday.use FaradayMiddleware::FollowRedirects
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
        end

        def listing(opts = {})
          response = @connection.get @parsed.request_uri, opts
          body = response.body
          set = ActiveSupport::JSON.decode(body)

          set.map do |item|
            {
              title:              item["title"],
              musicbrainz:        item["trackmbid"],
              identifier:         item["track_id"],
              at:                 item["playedtime_utc"] && Time.parse(item["playedtime_utc"]),
              artist:             item["artistname"],
              artist_musicbrainz: item["artistmbid"],
              artist_identifier:  item["artist_id"]
            }
          end
        end

      end
    end
  end
end