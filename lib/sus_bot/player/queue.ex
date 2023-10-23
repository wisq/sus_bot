defmodule SusBot.Player.Queue do
  alias Nostrum.Voice
  alias SusBot.Player.{Common, State}
  alias SusBot.Queue
  alias SusBot.Queue.Entry

  def queue(guild_id) do
    Common.call(guild_id, :queue)
  end

  def delete(guild_id, entry_id) do
    Common.call(guild_id, {:delete, entry_id})
  end

  def handle_call(:queue, _from, %State{now_playing: nil, queue: queue} = state) do
    {:reply, {:ok, queue}, state}
  end

  def handle_call(:queue, _from, %State{now_playing: %Entry{} = e, queue: queue} = state) do
    {:reply, {:ok, Queue.prepend(queue, e)}, state}
  end

  def handle_call({:delete, id}, _from, %State{now_playing: %Entry{id: id} = now} = state) do
    Voice.stop(state.guild_id)
    {:reply, {:ok, now}, %State{state | now_playing: nil}, {:continue, :play_next}}
  end

  def handle_call({:delete, entry_id}, _from, %State{} = state) do
    case Queue.pop(state.queue, entry_id) do
      {entry, queue} -> {:reply, {:ok, entry}, %State{state | queue: queue}}
      :error -> {:reply, {:error, :not_found}, state}
    end
  end
end
