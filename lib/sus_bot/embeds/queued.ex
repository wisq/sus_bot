defmodule SusBot.Embeds.Queued do
  alias Nostrum.Struct.Embed
  alias SusBot.Queue.Entry
  alias SusBot.Media.{Track, Playlist}

  import SusBot.Embeds.Common

  def generate(%Entry{media: %Track{} = track}) do
    %Embed{}
    |> Embed.put_title("Track Added")
    |> Embed.put_description(track.title)
    |> Embed.put_url(track.url)
    |> maybe_put_thumbnail(track.thumbnail)
  end

  def generate(%Entry{media: %Playlist{} = playlist}) do
    count = Enum.count(playlist.tracks)
    durations = playlist.tracks |> Enum.map(& &1.duration)

    %Embed{}
    |> Embed.put_title("Playlist Added")
    |> Embed.put_description(playlist.title)
    |> Embed.put_url(playlist.url)
    |> maybe_put_field("Channel", playlist.channel, true)
    |> Embed.put_field("Tracks", count, true)
    |> Embed.put_field("Duration", maybe_duration(durations), true)
    |> maybe_put_thumbnail(playlist.thumbnail)
  end

  defp maybe_duration(durations) do
    cond do
      Enum.all?(durations, &is_nil/1) ->
        format_duration(nil)

      Enum.any?(durations, &is_nil/1) ->
        durations
        |> Enum.reject(&is_nil/1)
        |> Enum.sum()
        |> format_duration()
        |> then(fn t -> "at least #{t}" end)

      true ->
        durations
        |> Enum.sum()
        |> format_duration()
    end
  end
end
