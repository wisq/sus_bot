defmodule SusBot.Embeds.NowPlaying do
  alias Nostrum.Struct.Embed
  alias SusBot.Player.Entry

  def generate(%Entry{} = entry) do
    %Embed{}
    |> Embed.put_title("Now Playing")
    |> Embed.put_description(entry.title)
    |> Embed.put_url(entry.url)
    |> Embed.put_field("Added By", entry.added_by, true)
    |> maybe_put_thumbnail(entry.thumbnail)
    |> maybe_put_duration(entry.duration)
  end

  defp maybe_put_thumbnail(embed, nil), do: embed
  defp maybe_put_thumbnail(embed, url), do: Embed.put_thumbnail(embed, url)

  defp maybe_put_duration(embed, nil), do: embed

  defp maybe_put_duration(embed, secs),
    do: Embed.put_field(embed, "Duration", format_duration(secs), true)

  defp format_duration(secs) do
    cond do
      secs <= 60 -> "#{secs}s"
      secs <= 3600 -> "#{div(secs, 60)}m #{rem(secs, 60)}s"
      true -> "#{div(secs, 3600)}h #{div(rem(secs, 3600), 60)}m #{rem(secs, 60)}s"
    end
  end
end
