# Media Mogul

A RUby library for listing content played in media shows with the ability to download where available.

It utilises rtmpdump and ffmpeg to convert the RTMP stream into a more usable m4a format.

# Copyright

Use this library for personal use only, where possible purchase music and support artists.

# Supported providers

* BBC (MediaMogul::Providers::BBC)

# Requirements

## Ruby

* Nokogiri

## Binaries

* rtmpdump
* ffmpeg with libfaac support

# Example

```ruby
show = MediaMogul::Providers::BBC::Show.new "http://www.bbc.co.uk/programmes/b006ww0v"
episode = show.latest_episode

title = episode.title
description = episode.description
author = episode.author
date = episode.date

tracks_played = episode.tracks_played

m4a_file = episode.as_m4a
```

MediaMogul::Models::Episode#as_m4a will call MediaMogul::Models::Episode#dump to obtain the highest bitrate RTMP dump, which it will then convert to m4a using ffmpeg's libfaac