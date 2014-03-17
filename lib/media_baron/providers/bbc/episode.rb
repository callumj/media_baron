require 'net/http'
require 'uri'
require 'nokogiri'
require 'tempfile'
require 'open4'
require 'cgi'

module MediaBaron
  module Providers
    module BBC
      class Episode < MediaBaron::Models::Episode

        attr_reader :episode_identifier, :media_identifier

        def initialize(addr, opts = {})
          if addr.match(REGEX_PARSE)
            @episode_identifier = $2
            addr = "http://www.bbc.co.uk/iplayer/playlist/#{@episode_identifier}"
          else
            @episode_identifier = addr
            addr = "http://www.bbc.co.uk/iplayer/playlist/#{addr}"
          end
          super

          response = Net::HTTP.get_response(URI.parse self.address)
          @playlist = Nokogiri::XML response.body
          @playlist.remove_namespaces!

          populate_values
        end

        def populate_values
          @title = @playlist.xpath("playlist/title").first.text
          @description = @playlist.xpath("playlist/summary").first.text
          @author = @playlist.xpath("playlist/item/passionSite").first.text

          item_ref = @playlist.xpath("playlist/item[@kind='radioProgramme']").first
          @media_identifier = item_ref.attribute("identifier").value unless item_ref.nil?

          broadcast_date = item_ref.xpath("broadcast").first
          unless broadcast_date.nil?
            @date = Time.parse(broadcast_date)
          end

          @file_name = "#{@title.gsub(MediaBaron::REGEX_BAD_TITLE, "-")}"
          if @date.present?
            @file_name << "-#{@date.strftime("%d-%m-%Y")}"
          end

          @file_name << ".m4a"

          episode_response = Net::HTTP.get_response(URI.parse "http://www.bbc.co.uk/programmes/#{@episode_identifier}")
          @episode_page = Nokogiri::HTML episode_response.body
          @episode_page.remove_namespaces!
        end

        def tracks_played
          music_segments = @episode_page.xpath "//ul[@class='segments']//li[@typeof='po:MusicSegment']"
          music_segments.map do |list_item|
            artist = list_item.xpath(".//span[@property='foaf:name']").first.text
            track = list_item.xpath(".//span[@property='dc:title']").first.text
            label = list_item.xpath(".//span[@class='record-label']").first.text rescue nil

            {:artist => artist, :track => track, :label => label}
          end
        end

        def media_document
          return @meta unless @meta.nil?

          meta_data_url = URI.parse "http://open.live.bbc.co.uk/mediaselector/5/select/version/2.0/mediaset/pc/transferformat/plain/vpid/#{@media_identifier}"
          document_response = Net::HTTP.get_response meta_data_url
          @meta = Nokogiri::XML document_response.body
          @meta.remove_namespaces!

          @meta
        end

        def available_formats
          streams = []
          media_document.xpath("//mediaSelection/media[@encoding='aac']").each do |element|
            data = {:bitrate => element.attribute("bitrate").to_s }

            connection_object = element.xpath(element, "connection").first
            data[:application] = connection_object.attribute("application").to_s
            data[:string] = connection_object.attribute("authString").to_s.gsub("&amp;", "&")
            data[:identifier] = connection_object.attribute("identifier").to_s
            data[:server] = connection_object.attribute("server").to_s

            streams << data
          end

          streams.sort {|a,b| b[:bitrate].to_i <=> a[:bitrate].to_i}
        end

        def dump(bitrate = nil)
          streams = available_formats
          target = streams.first

          file = Tempfile.new(["rtmpdump",".flv"])
          application_ref = "#{target[:application]}?#{target[:string]}"
          rtmpdump_args = [MediaBaron.rtmpdump_bin, "-r \"rtmp://#{target[:server]}:1935/#{application_ref}\"", "-a \"#{application_ref}\"", "-y \"#{target[:identifier]}\"", "-o \"#{file.path}\""]
          dump_command =  rtmpdump_args.join " "
          STDOUT.puts "Calling: #{dump_command}"

          Open4::popen4(dump_command) do |pid, stdin, stdout, stderr|
            STDOUT.puts "pid        : #{ pid }"
            STDOUT.puts "stdout     : #{ stdout.read.strip }"
            STDOUT.puts "stderr     : #{ stderr.read.strip }"
          end

          file
        end
      end
    end
  end
end
