defmodule SusBot.Embeds.Common do
  def format_duration(nil), do: "unknown"

  def format_duration(secs) when is_integer(secs) do
    cond do
      secs <= 60 -> "#{secs}s"
      secs <= 3600 -> "#{div(secs, 60)}m #{rem(secs, 60)}s"
      true -> "#{div(secs, 3600)}h #{div(rem(secs, 3600), 60)}m #{rem(secs, 60)}s"
    end
  end
end
