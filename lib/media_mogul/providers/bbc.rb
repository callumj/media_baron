require 'media_mogul/providers/bbc/show'
require 'media_mogul/providers/bbc/episode'

module MediaMogul
  module Providers
    module BBC
      REGEX_PARSE = /(programmes|episode)\/([A-Za-z0-9]*)\/?/
    end
  end
end