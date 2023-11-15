defmodule SusBot.Player.Common do
  alias Nostrum.Api, as: Discord

  def player_name(guild_id) when is_integer(guild_id) do
    :"susbot_player_#{guild_id}"
  end

  def cast(guild_id, message) do
    player_name(guild_id) |> GenServer.cast(message)
  end

  def call(guild_id, message, timeout \\ 5000) do
    try do
      player_name(guild_id) |> GenServer.call(message, timeout)
    catch
      :exit, {:noproc, _} -> {:error, :not_running}
    end
  end

  def status_message(message, state) do
    state.config.status_channel
    |> Discord.create_message(message)
  end
end
