# Radio Keeper

This Ruby library provides the ability to download online radio shows.

It utilises rtmpdump and ffmpeg to convert the RTMP stream into a more usable m4a format.

# Copyright

Use this library for personal use only, where possible purchase music and support artists.

# Requirements

## Ruby

* Nokogiri

## Binaries

* rtmpdump
* ffmpeg with libfaac support

# Example

```ruby
show = RadioKeeper::Providers::BBC::Show.new "http://www.bbc.co.uk/programmes/b006ww0v"
episode = show.latest_episode

m4a_file = episode.as_m4a
```

RadioKeeper::Models::Episode#as_m4a will call RadioKeeper::Models::Episode#dump to obtain the highest bitrate RTMP dump, which it will then convert to m4a using ffmpeg's libfaac

# Supported providers

* BBC (RadioKeeper::Providers::BBC)