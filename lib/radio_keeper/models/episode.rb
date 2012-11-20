module RadioKeeper
  module Models
    class Episode

      attr_accessor :address
      attr_reader :title, :description, :date, :file_name, :author

      def initialize(addr, opts = {})
        raise "Required binaries (ffmpeg & rtmpdump) are not available" unless RadioKeeper.stable?

        self.address = addr

        self
      end

      def dump(bitrate = nil)
      end

      def tracks_played
        []
      end

      def as_m4a(bitrate = nil)
        file = dump(bitrate)

        return nil if file.nil?

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

        if RadioKeeper.qt_faststart_bin.nil?
          output
        else
          fast_file = Tempfile.new(["qt_faststart",".m4a"])

          `#{RadioKeeper.qt_faststart_bin} #{output.path} #{fast_file.path}`

          fast_file.seek(0)
          if fast_file.size > 0
            output.unlink
            fast_file
          else
            output.seek(0)
            output
          end
        end
      end

    end
  end
end