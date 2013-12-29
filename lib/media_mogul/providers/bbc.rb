require 'media_baron/providers/bbc/show'
require 'media_baron/providers/bbc/episode'

module MediaBaron
  module Providers
    module BBC
      REGEX_PARSE = /(programmes|episode)\/([A-Za-z0-9]*)\/?/
    end
  end
end