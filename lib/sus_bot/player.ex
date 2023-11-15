defmodule SusBot.Player do
  use GenServer, restart: :temporary
  require Logger

  alias __MODULE__, as: P

  @supervisor SusBot.Player.Supervisor
  def supervisor, do: @supervisor

  defdelegate available?(guild_id), to: P.Lifecycle
  defdelegate start_link(opts), to: P.Lifecycle
  defdelegate shutdown(guild_id, reason), to: P.Lifecycle
  def leave(guild_id), do: shutdown(guild_id, :leave)

  defdelegate append(guild_id, channel_id, tracks, user), to: P.Append
  defdelegate skip(guild_id), to: P.Skip
  defdelegate stop(guild_id), to: P.Stop
  defdelegate wakeup(guild_id), to: P.Playback

  defdelegate queue(guild_id), to: P.Queue
  defdelegate delete(guild_id, entry_id), to: P.Queue

  @impl true
  defdelegate init(term), to: P.Lifecycle

  @impl true
  def handle_call({:append, entry}, from, state),
    do: P.Append.handle_call({:append, entry}, from, state)

  @impl true
  def handle_call(:stop = c, from, state), do: P.Stop.handle_call(c, from, state)
  @impl true
  def handle_call(:skip = c, from, state), do: P.Skip.handle_call(c, from, state)
  @impl true
  def handle_call(:queue = c, from, state), do: P.Queue.handle_call(c, from, state)
  @impl true
  def handle_call({:delete, _} = c, from, state), do: P.Queue.handle_call(c, from, state)

  @impl true
  def handle_cast(:wakeup, state), do: P.Playback.handle_cast(:wakeup, state)

  @impl true
  def handle_continue(:play_next, state), do: P.Playback.handle_continue(:play_next, state)

  @impl true
  def handle_info({:assert_ready, channel}, state),
    do: P.Lifecycle.handle_info({:assert_ready, channel}, state)

  @impl true
  defdelegate terminate(reason, state), to: P.Lifecycle
end
