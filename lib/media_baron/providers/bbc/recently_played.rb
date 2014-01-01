require 'nokogiri'
require 'addressable/uri'
require 'faraday'
require 'faraday_middleware'

module MediaBaron
  module Providers
    module BBC
      class RecentlyPlayed

        def initialize(identifier = "radio1")
          replaced = MediaBaron::Providers::BBC::RECENTLY_PLAYED.gsub("$1", identifier)
          @parsed = Addressable::URI.parse replaced
          @connection = Faraday.new(url: @parsed.origin) do |faraday|
            faraday.request  :url_encoded
            faraday.use FaradayMiddleware::FollowRedirects
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
        end

        def listing(opts = {})
          response = @connection.get @parsed.request_uri, opts
          page = Nokogiri::HTML response.body

          set = []

          current = page.xpath("//div[@id='nowPlaying']").first
          if current
            name   = current.xpath(".//span[@class='trackName']").text
            artist = current.xpath(".//span[@class='trackArtist']/a").text
            return unless name && artist
            track_identifier  = current.xpath(".//span[@data-type='track_segment']").first.try(:[], "data-id").try { |t| t.split("#")[0] }
            artist_identifier = self.class.music_brainz_id current.xpath(".//a[@id='nowPlayingLink']").first.try(:[], :href)

            set << {title: name.strip, artist: artist, identifier: track_identifier, artist_musicbrainz: artist_identifier}
          end

          time_point = Time.now.in_time_zone("London")
          page.xpath("//div[@id='recent-tracks']/a").each do |node|
            name   = node.xpath(".//p[@class='trackName']").text
            artist = node.xpath(".//p[@class='trackArtist']").text

            next unless name && artist

            track_identifier  = node["data-trackid"].try { |t| t.split("#")[0] }
            artist_identifier = self.class.music_brainz_id node["href"]
            set << {title: name, artist: artist, identifier: track_identifier, artist_musicbrainz: artist_identifier, at: time_point}
          end

          set
        end

        def self.music_brainz_id(addr)
          return unless addr
          addr.match(/\/music\/artists\/([^.]+)\.mp/).try :[], 1
        end
      end
    end
  end
end