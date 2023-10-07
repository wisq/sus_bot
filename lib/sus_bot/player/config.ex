defmodule SusBot.Player.Config do
  @enforce_keys [:status_channel]
  defstruct(status_channel: nil)

  def parse(enum) do
    enum |> Map.new(&from_config/1)
  end

  defp from_config({guild_id, fields}) when is_integer(guild_id) do
    {guild_id, struct!(__MODULE__, fields)}
  end
end
