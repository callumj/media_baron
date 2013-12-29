module MediaMogul
  module Models
    class Show

      attr_accessor :address
      attr_reader :title, :description

      def initialize(addr, opts = {})
        self.address = addr

        self
      end

      def latest_episode
      end
    end
  end
end