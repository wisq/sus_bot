defmodule SusBot.Media.Playlist do
  @enforce_keys [:title, :url, :tracks]
  defstruct(
    title: nil,
    url: nil,
    thumbnail: nil,
    tracks: []
  )
end
