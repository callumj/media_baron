require 'radio_keeper/providers/bbc/show'
require 'radio_keeper/providers/bbc/episode'

module RadioKeeper
  module Providers
    module BBC
      REGEX_PARSE = /(programmes|episode)\/([A-Za-z0-9]*)\/?/
    end
  end
end