defmodule SusBot.Media.Playlist do
  @enforce_keys [:title, :channel, :url, :tracks]
  defstruct(
    title: nil,
    channel: nil,
    url: nil,
    thumbnail: nil,
    tracks: []
  )
end
