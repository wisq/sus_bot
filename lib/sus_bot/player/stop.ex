defmodule SusBot.Player.Stop do
  alias Nostrum.Voice
  alias SusBot.Player.{Common, State}
  alias SusBot.Queue.Entry

  def stop(guild_id) do
    Common.call(guild_id, :stop)
  end

  def handle_call(:stop, _from, state) do
    case state.now_playing do
      %Entry{} ->
        Voice.stop(state.guild_id)
        {:reply, :ok, %State{state | now_playing: nil, mode: :stopped}}

      nil ->
        {:reply, {:error, :stopped}, state}
    end
  end
end
