require 'nokogiri'
require 'addressable/uri'

module MediaBaron
  module Providers
    module TripleJ
      class Show < MediaBaron::Models::Show

        def initialize(addr, opts = {})

          unless addr.start_with?("http://")
            addr = "#{MediaBaron::Providers::TripleJ::OFFICIAL_URL}/#{addr}"
          end

          super addr, opts

          @parsed_uri = Addressable::URI.parse self.address
          @connection = Faraday.new(url: @parsed_uri.origin) do |faraday|
            faraday.use FaradayMiddleware::FollowRedirects
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end

          response = @connection.get(@parsed_uri.request_uri)

          @page = Nokogiri::HTML response.body
          @page.remove_namespaces!

          populate_values

          self
        end

        def populate_values
          @title = @page.xpath("//title").text.split(/\s?\|\s+/)[-2]
          @description = @page.xpath("//meta[@name='DC.description']|//meta[@name='description']|//meta[@name='Description']|//meta[@property='og:description']").attribute('content').try(:value)
        end

        def latest_episode_ref
          # look up JPlay
          j_play = JPlay.new
          addr = j_play.playlists_address title
          return unless addr

          set = j_play.show_identifiers addr
          return unless set.present?
          "#{addr}##{set.first[0]}"
        end

        def latest_episode
          ref = latest_episode_ref
          ref.nil? ? nil : Episode.new(ref)
        end

      end
    end
  end
end