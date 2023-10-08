defmodule SusBot.Media.Track do
  @enforce_keys [:title, :url, :play_type]
  defstruct(
    title: nil,
    url: nil,
    play_type: nil,
    thumbnail: nil,
    duration: nil
  )
end
