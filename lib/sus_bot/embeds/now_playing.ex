defmodule SusBot.Embeds.NowPlaying do
  alias Nostrum.Struct.Embed
  alias SusBot.Playlist.Entry

  import SusBot.Embeds.Common

  def generate(%Entry{} = entry) do
    %Embed{}
    |> Embed.put_title("Now Playing")
    |> Embed.put_description(entry.title)
    |> Embed.put_url(entry.url)
    |> maybe_put_thumbnail(entry.thumbnail)
    |> Embed.put_field("Added By", entry.added_by, true)
    |> Embed.put_field("Duration", format_duration(entry.duration), true)
  end

  defp maybe_put_thumbnail(embed, nil), do: embed
  defp maybe_put_thumbnail(embed, url), do: Embed.put_thumbnail(embed, url)
end
