defmodule SusBot.Player.Append do
  alias SusBot.Player
  alias SusBot.Player.State
  alias SusBot.Playlist
  alias SusBot.Playlist.Entry

  @supervisor Player.supervisor()

  def append(guild_id, %Entry{} = entry, channel_id)
      when is_integer(guild_id) and is_integer(channel_id) do
    with {:ok, pid} <- launch(guild_id, channel_id) do
      GenServer.call(pid, {:append, entry})
    end
  end

  def handle_call({:append, entry}, _from, state) do
    id = state.next_id
    entry = %Entry{entry | id: id}
    state = %State{state | next_id: id + 1, playlist: Playlist.append(state.playlist, entry)}

    {:reply, {:ok, entry}, state, {:continue, :play_next}}
  end

  defp launch(guild_id, channel_id) do
    opts = [guild_id: guild_id, channel_id: channel_id]

    case DynamicSupervisor.start_child(@supervisor, {Player, opts}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end
end
