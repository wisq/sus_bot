defmodule SusBot.Media.Track do
  @enforce_keys [:title, :channel, :url, :play_type]
  defstruct(
    title: nil,
    channel: nil,
    url: nil,
    play_type: nil,
    thumbnail: nil,
    duration: nil
  )
end
