defmodule SusBot.Embeds.Deleted do
  alias Nostrum.Struct.Embed
  alias SusBot.Queue.Entry

  import SusBot.Embeds.Common

  def generate(%Entry{media: media}) do
    %Embed{}
    |> Embed.put_title("Track Deleted")
    |> Embed.put_description(media.title)
    |> Embed.put_url(media.url)
    |> maybe_put_thumbnail(media.thumbnail)
  end
end
