require 'nokogiri'
require 'tempfile'
require 'addressable/uri'

module MediaBaron
  module Providers
    module TripleJ
      class JPlay

        def initialize
          @parsed = Addressable::URI.parse MediaBaron::Providers::TripleJ::J_PLAY
          @connection = Faraday.new(url: @parsed.origin) do |faraday|
            faraday.request  :url_encoded
            faraday.use FaradayMiddleware::FollowRedirects
            faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
          end
        end

        def playlists_address(name)
          response = @connection.get @parsed.request_uri
          page     = Nokogiri::HTML response.body
          @view_state = page.xpath("//input[@id='__VIEWSTATE']").first.try :[], :value
          links = page.xpath "//a[starts-with(@id, 'dlCategories_')]"
          best = links.sort_by do |node|
            node.text.levenshtein_similar name
          end.last
          return unless best
          
          best.attribute("href").try :value
        end

        def show_identifiers(playlists_address_or_id)
          playlists_address_or_id = "SearchPlaylists.aspx?PlaylistNameID=#{playlists_address_or_id}" if playlists_address_or_id.is_a?(Fixnum)
          jump_url = Addressable::URI.join @parsed, playlists_address_or_id

          response = @connection.get jump_url.request_uri
          page     = Nokogiri::HTML response.body

          @view_state = page.xpath("//input[@id='__VIEWSTATE']").first.try :[], :value
          @event_validation = page.xpath("//input[@id='__EVENTVALIDATION']").first.try :[], :value

          t = page.xpath("//a[contains(@id, 'dgPlaylistsAvailableForName')]").map do |node|
            href = node["href"]
            ex = href.match(/doPostBack\('([^']+)'/)[1]
            next unless ex
            [ex, node.text]
          end

          Hash[t]
        end

        def listing(playlists_address_or_id, show_identifier)
          if @view_state.nil? || @event_validation.nil?
            # need to force a continuation of ASP.NET view state
            show_identifiers playlists_address_or_id
          end

          playlists_address_or_id = "SearchPlaylists.aspx?PlaylistNameID=#{playlists_address_or_id}" if playlists_address_or_id.is_a?(Fixnum)
          jump_url = Addressable::URI.join @parsed, playlists_address_or_id

          response = @connection.post jump_url.request_uri, {"__VIEWSTATE" => @view_state, "__EVENTARGUMENT" => "", "__EVENTTARGET" => show_identifier, "__EVENTVALIDATION" => @event_validation}
          page     = Nokogiri::HTML response.body

          date = page.xpath("//span[@id='txtPlaylistDate']").try :text
          parsed_date = date && Time.parse(date)

          page.xpath("//table[@id='dgPlaylist']/tr").map do |node|
            children = node.xpath("td")
            next if children.first.text == "Time"

            next unless children.count == 5
            
            timing = children[0].text
            link   = children[1].try { |l| l.css("a").first.try :[], :href }
            name   = children[2].text.strip

            time_point = nil
            if timing && parsed_date
              hour, min = timing.split(":").map(&:to_i)
              time_point = parsed_date + (hour.hours + min.minutes)
            end
            
            {
              timing: time_point,
              link: link,
              name: name
            }
          end
        end

      end
    end
  end
end