defmodule SusBot.Embeds.NowPlaying do
  alias Nostrum.Struct.Embed

  alias SusBot.Queue.Entry
  alias SusBot.Media.Track

  import SusBot.Embeds.Common

  def generate(%Entry{} = entry, %Track{} = track) do
    %Embed{}
    |> Embed.put_title("Now Playing")
    |> Embed.put_description(track.title)
    |> Embed.put_url(track.url)
    |> maybe_put_thumbnail(track.thumbnail)
    |> Embed.put_field("Channel", track.channel, true)
    |> Embed.put_field("Added By", entry.added_by.username, true)
    |> Embed.put_field("Duration", format_duration(track.duration), true)
  end

  defp maybe_put_thumbnail(embed, nil), do: embed
  defp maybe_put_thumbnail(embed, url), do: Embed.put_thumbnail(embed, url)
end
