module RadioKeeper
  module Providers
    module BBC
      class Episode < RadioKeeper::Models::Episode

        attr_reader :episode_identifier, :media_identifier

        def initialize(addr, opts = {})
          if addr.match(REGEX_PARSE)
            @episode_identifier = $2
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

          item_ref = @playlist.xpath("playlist/item").first
          @media_identifier = item_ref.attribute "identifier" unless item_ref.nil?

          @date = Time.parse item_ref.xpath("broadcast").first

          @file_name = "#{@title.gsub(RadioKeeper::REGEX_BAD_TITLE, "-")}.m4a"
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
          rtmpdump_args = [RadioKeeper.rtmpdump_bin, "-r \"rtmp://#{target[:server]}:1935/#{application_ref}\"", "-a \"#{application_ref}\"", "-y \"#{target[:identifier]}\"", "-q", "-o \"#{file.path}\""]
          dump_command =  rtmpdump_args.join " "
          `#{dump_command}`

          file
        end

        def as_m4a(bitrate = nil)
          file = dump(bitrate)

          raise "Couldn't locate the file (#{file.path})" unless File.exists?(file.path)
          ffmpeg_base = "#{RadioKeeper.ffmpeg_bin} -i #{file.path}"
          bitrate = 128
          Open3.popen3(ffmpeg_base) do |stdin, stdout, stderr, wait_thr|
            stderr_bitrate = REGEX_FFMPEG.match(stderr.read())
            if (stderr_bitrate.nil?)
              stdout_bitrate = REGEX_FFMPEG.match(stdout.read())
              bitrate = stdout_bitrate[1].to_i unless stdout_bitrate.nil?
            else
              bitrate = stderr_bitrate[1].to_i
            end
          end

          output = Tempfile.new(["ffmpeg",".m4a"])
          ffmpeg_full = "#{ffmpeg_base} -metadata artist=\"#{@author}\" -metadata title=\"#{@title}\" -metadata comments=\"#{@description}\" -acodec libfaac -ab #{bitrate}k -ar 44100 -ac 2 -y -loglevel panic #{output.path}"
          `#{ffmpeg_full}`

          file.unlink

          output
        end
      end
    end
  end
end