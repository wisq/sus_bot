defmodule SusBot.Embeds.Queued do
  alias Nostrum.Struct.Embed
  alias SusBot.Player.Entry

  def generate(%Entry{} = entry) do
    %Embed{}
    |> Embed.put_title("Track Added")
    |> Embed.put_description(entry.title)
    |> Embed.put_url(entry.url)
    |> maybe_put_thumbnail(entry.thumbnail)
  end

  defp maybe_put_thumbnail(embed, nil), do: embed
  defp maybe_put_thumbnail(embed, url), do: Embed.put_thumbnail(embed, url)
end
