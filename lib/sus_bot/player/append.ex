defmodule SusBot.Player.Append do
  alias Nostrum.Struct.User
  alias SusBot.Player
  alias SusBot.Player.State
  alias SusBot.Queue
  alias SusBot.Queue.Entry

  @supervisor Player.supervisor()

  def append(guild_id, channel_id, tracks, %User{} = user)
      when is_integer(guild_id) and is_integer(channel_id) do
    entry = Entry.new(tracks, user)

    with {:ok, pid} <- launch(guild_id, channel_id) do
      GenServer.call(pid, {:append, entry})
    end
  end

  def handle_call({:append, entry}, _from, state) do
    id = state.next_id
    entry = %Entry{entry | id: id}
    state = %State{state | next_id: id + 1, queue: Queue.append(state.queue, entry)}

    {:reply, {:ok, entry}, state, {:continue, :play_next}}
  end

  defp launch(guild_id, channel_id) do
    opts = [guild_id: guild_id, channel_id: channel_id]

    case DynamicSupervisor.start_child(@supervisor, {Player, opts}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, :missing_access} = err -> err
    end
  end
end
