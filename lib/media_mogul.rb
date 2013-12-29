require 'bundler'
Bundler.require :default

require 'media_mogul/models'
require 'media_mogul/tools'
require 'media_mogul/providers'

require 'active_support/all'

module MediaMogul

  REGEX_FFMPEG = /bitrate: ([0-9]*)/
  REGEX_BAD_TITLE = /[^A-Za-z0-9-]+/

  def self.stable?
    # check if the required binaries are available
    rtmpdump_bin.present? && ffmpeg_bin.present?
  end

  def self.rtmpdump_bin
    MediaMogul::Tools.find_executable "rtmpdump"
  end

  def self.ffmpeg_bin
    MediaMogul::Tools.find_executable "ffmpeg"
  end

  def self.qt_faststart_bin
    MediaMogul::Tools.find_executable "qt-faststart"
  end

end