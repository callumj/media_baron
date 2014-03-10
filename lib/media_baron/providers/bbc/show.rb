require 'net/http'
require 'uri'
require 'nokogiri'
require 'tempfile'
require 'open3'
require 'cgi'

module MediaBaron
  module Providers
    module BBC
      class Show < MediaBaron::Models::Show

        def initialize(addr, opts = {})

          if addr.match(REGEX_PARSE)
            addr = "http://www.bbc.co.uk/programmes/#{$2}"
          else
            unless addr.start_with?("http://")
              addr = "http://www.bbc.co.uk/programmes/#{addr}"
            end
          end

          super addr, opts

          response = Net::HTTP.get_response(URI.parse self.address)

          @page = Nokogiri::HTML response.body
          @page.remove_namespaces!

          populate_values

          self
        end

        def populate_values
          @title = @page.xpath("//div[@class='br-masthead__title']/div/a|//*[@typeof='po:Brand']").attribute('title').value
          @description = @page.xpath("//*[@property='og:description']").attribute('content').value
        end

        def latest_episode_ref
          input_ref = nil
          ref_point = @page.xpath("//h2[contains(text(),'On demand')]").first

          input_ref = nil

          while (ref_point != nil && (input_ref = ref_point['href'] || ref_point['resource']).nil?)
            ref_point = ref_point.next_element
          end

          return nil if input_ref.nil?

          input_ref.match(MediaBaron::Providers::BBC::REGEX_PARSE) ? $2 : nil
        end

        def latest_episode
          ref = latest_episode_ref
          ref.nil? ? nil : Episode.new(ref)
        end

      end
    end
  end
end