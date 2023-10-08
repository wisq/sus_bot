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
    duration = playlist.tracks |> Enum.map(& &1.duration) |> Enum.sum()

    %Embed{}
    |> Embed.put_title("Playlist Added")
    |> Embed.put_description(playlist.title)
    |> Embed.put_url(playlist.url)
    |> Embed.put_field("Tracks", count, true)
    |> Embed.put_field("Duration", format_duration(duration), true)
  end

  defp maybe_put_thumbnail(embed, nil), do: embed
  defp maybe_put_thumbnail(embed, url), do: Embed.put_thumbnail(embed, url)
end
