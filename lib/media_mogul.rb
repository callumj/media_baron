require 'bundler'
Bundler.require :default

require 'media_baron/models'
require 'media_baron/tools'
require 'media_baron/providers'

require 'active_support/all'

module MediaBaron

  REGEX_FFMPEG = /bitrate: ([0-9]*)/
  REGEX_BAD_TITLE = /[^A-Za-z0-9-]+/

  def self.stable?
    # check if the required binaries are available
    rtmpdump_bin.present? && ffmpeg_bin.present?
  end

  def self.rtmpdump_bin
    MediaBaron::Tools.find_executable "rtmpdump"
  end

  def self.ffmpeg_bin
    MediaBaron::Tools.find_executable "ffmpeg"
  end

  def self.qt_faststart_bin
    MediaBaron::Tools.find_executable "qt-faststart"
  end

end