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

      def as_m4a(bitrate = nil)
      end

    end
  end
end