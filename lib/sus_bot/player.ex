defmodule SusBot.Player do
  use GenServer
  require Logger

  alias Nostrum.Api, as: Discord
  alias Nostrum.Voice
  alias Nostrum.Cache.ChannelCache

  alias SusBot.Player.{Playlist, Entry}
  alias SusBot.Embeds.NowPlaying

  @supervisor SusBot.Player.Supervisor
  def supervisor, do: @supervisor

  defmodule Config do
    @enforce_keys [:status_channel]
    defstruct(status_channel: nil)

    def parse(enum) do
      enum |> Map.new(&from_config/1)
    end

    defp from_config({guild_id, fields}) when is_integer(guild_id) do
      {guild_id, struct!(__MODULE__, fields)}
    end
  end

  defmodule State do
    @enforce_keys [:guild_id, :config]
    defstruct(
      guild_id: nil,
      config: nil,
      playing: nil,
      next_id: 1,
      playlist: Playlist.new()
    )
  end

  @configs Application.compile_env(:sus_bot, __MODULE__, []) |> Config.parse()

  def available?(guild_id), do: Map.has_key?(@configs, guild_id)

  def append(guild_id, %Entry{} = entry, channel_id)
      when is_integer(guild_id) and is_integer(channel_id) do
    with {:ok, pid} <- launch(guild_id, channel_id) do
      GenServer.call(pid, {:append, entry})
    end
  end

  def stop(guild_id) do
    case player_name(guild_id) |> GenServer.whereis() do
      pid when is_pid(pid) -> GenServer.call(pid, :stop)
      nil -> {:error, :not_running}
    end
  end

  def wakeup(guild_id) do
    player_name(guild_id)
    |> GenServer.cast(:wakeup)
  end

  defp launch(guild_id, channel_id) do
    opts = [guild_id: guild_id, channel_id: channel_id]

    case DynamicSupervisor.start_child(@supervisor, {__MODULE__, opts}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
    end
  end

  def start_link(opts) do
    {guild_id, opts} = Keyword.pop!(opts, :guild_id)
    {channel_id, opts} = Keyword.pop!(opts, :channel_id)
    config = Map.fetch!(@configs, guild_id)
    opts = Keyword.put_new(opts, :name, player_name(guild_id))

    GenServer.start_link(__MODULE__, {guild_id, channel_id, config}, opts)
  end

  defp player_name(guild_id) when is_integer(guild_id), do: :"susbot_player_#{guild_id}"

  @impl true
  def init({guild_id, channel_id, config}) do
    ensure_channel_cached(channel_id)
    Voice.join_channel(guild_id, channel_id)

    {:ok,
     %State{
       guild_id: guild_id,
       config: config
     }}
  end

  @impl true
  def handle_call({:append, entry}, _from, state) do
    id = state.next_id
    entry = %Entry{entry | id: id}
    state = %State{state | next_id: id + 1, playlist: Playlist.append(state.playlist, entry)}

    {:reply, {:ok, id}, state, {:continue, :play_next}}
  end

  @impl true
  def handle_call(:stop, _from, state) do
    case state.playing do
      %Entry{} ->
        Voice.stop(state.guild_id)
        {:reply, :ok, %State{state | playing: nil}}

      nil ->
        {:reply, {:error, :not_playing}, state}
    end
  end

  @impl true
  def handle_cast(:wakeup, state) do
    {:noreply, state, {:continue, :play_next}}
  end

  @impl true
  def handle_continue(:play_next, state) do
    cond do
      Voice.playing?(state.guild_id) ->
        Logger.debug("[Voice #{state.guild_id}] Already playing")
        {:noreply, state}

      !Voice.ready?(state.guild_id) ->
        Logger.debug("[Voice #{state.guild_id}] Not ready")
        {:noreply, state}

      true ->
        case Playlist.pop_next(state.playlist) do
          {entry, new_playlist} ->
            Logger.debug("[Voice #{state.guild_id}] Playing #{inspect(entry, pretty: true)}")

            c_id = state.config.status_channel
            Discord.create_message(c_id, embeds: [NowPlaying.generate(entry)])
            Voice.play(state.guild_id, entry.url, entry.play_type)

            {:noreply, %State{state | playing: entry, playlist: new_playlist}}

          :error ->
            Logger.debug("[Voice #{state.guild_id}] Empty playlist")
            {:noreply, %State{state | playing: nil}}
        end
    end
  end

  # Voice requires the channel be cached,
  # and for some reason, that's not happening automatically.
  defp ensure_channel_cached(channel_id) do
    case ChannelCache.get(channel_id) do
      {:ok, _} -> :ok
      {:error, :not_found} -> Discord.get_channel!(channel_id) |> ChannelCache.create()
    end
  end
end
