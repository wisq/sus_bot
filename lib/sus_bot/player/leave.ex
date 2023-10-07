defmodule SusBot.Player.Leave do
  alias SusBot.Player.Common

  def leave(guild_id) do
    try do
      :ok = Common.player_name(guild_id) |> GenServer.stop()
    catch
      :exit, {:noproc, _} -> {:error, :not_running}
    end
  end
end
