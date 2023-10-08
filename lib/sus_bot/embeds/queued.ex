defmodule SusBot.Embeds.Queued do
  alias Nostrum.Struct.Embed
  alias SusBot.Playlist.Entry
  alias SusBot.Track

  def generate(%Entry{tracks: [%Track{} = track]}) do
    %Embed{}
    |> Embed.put_title("Track Added")
    |> Embed.put_description(track.title)
    |> Embed.put_url(track.url)
    |> maybe_put_thumbnail(track.thumbnail)
  end

  def generate(%Entry{tracks: tracks}) do
    count = Enum.count(tracks)

    %Embed{}
    |> Embed.put_title("#{count} Tracks Added")
  end

  defp maybe_put_thumbnail(embed, nil), do: embed
  defp maybe_put_thumbnail(embed, url), do: Embed.put_thumbnail(embed, url)
end
