defmodule SusBot.Player.Skip do
  alias Nostrum.Voice
  alias SusBot.Player.{Common, State}
  alias SusBot.Playlist.Entry

  def skip(guild_id) do
    Common.call(guild_id, :skip)
  end

  def handle_call(:skip, _from, state) do
    case state.now_playing do
      %Entry{} ->
        Voice.stop(state.guild_id)
        {:reply, :ok, %State{state | now_playing: nil}, {:continue, :play_next}}

      nil ->
        {:reply, {:error, :stopped}, state}
    end
  end
end
