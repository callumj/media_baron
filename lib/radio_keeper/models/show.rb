module RadioKeeper
  module Models
    class Show

      attr_accessor :address
      attr_reader :title, :description

      def initialize(addr, opts = {})
        raise "Required binaries (ffmpeg & rtmpdump) are not available" unless RadioKeeper.stable?

        self.address = addr

        self
      end

      def latest_episode
      end
    end
  end
end