defmodule SusBot.Embeds.Common do
  alias Nostrum.Struct.Embed

  def format_duration(nil), do: "unknown"

  def format_duration(secs) when is_integer(secs) do
    cond do
      secs <= 60 -> "#{secs}s"
      secs <= 3600 -> "#{div(secs, 60)}m #{rem(secs, 60)}s"
      true -> "#{div(secs, 3600)}h #{div(rem(secs, 3600), 60)}m #{rem(secs, 60)}s"
    end
  end

  def maybe_put_thumbnail(embed, nil), do: embed
  def maybe_put_thumbnail(embed, url), do: Embed.put_thumbnail(embed, url)

  def maybe_put_field(embed, _, nil, _), do: embed

  def maybe_put_field(embed, field, value, inline),
    do: Embed.put_field(embed, field, value, inline)
end
