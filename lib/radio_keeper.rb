require 'radio_keeper/models'
require 'radio_keeper/tools'
require 'radio_keeper/providers'

require 'active_support/all'

module RadioKeeper

  REGEX_FFMPEG = /bitrate: ([0-9]*)/
  REGEX_BAD_TITLE = /[^A-Za-z0-9-]+/

  def self.stable?
    # check if the required binaries are available
    rtmpdump_bin.present? && ffmpeg_bin.present?
  end

  def self.rtmpdump_bin
    RadioKeeper::Tools.find_executable "rtmpdump"
  end

  def self.ffmpeg_bin
    RadioKeeper::Tools.find_executable "ffmpeg"
  end

end