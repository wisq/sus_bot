defmodule SusBot.Player.Lifecycle do
  require Logger
  alias Nostrum.Api, as: Discord
  alias Nostrum.Voice
  alias Nostrum.Cache.GuildCache
  alias SusBot.Player
  alias SusBot.Player.{Common, Config, State}

  @configs Application.compile_env(:sus_bot, Player, []) |> Config.parse()

  def available?(guild_id), do: Map.has_key?(@configs, guild_id)

  def start_link(opts) do
    {guild_id, opts} = Keyword.pop!(opts, :guild_id)
    {channel_id, opts} = Keyword.pop!(opts, :channel_id)
    config = Map.fetch!(@configs, guild_id)
    opts = Keyword.put_new(opts, :name, Common.player_name(guild_id))

    GenServer.start_link(Player, {guild_id, channel_id, config}, opts)
  end

  def init({guild_id, channel_id, config}) do
    with {:ok, guild} <- GuildCache.get(guild_id),
         {:ok, channel} <- guild.channels |> Map.fetch(channel_id) do
      Voice.join_channel(guild_id, channel_id)

      Process.send_after(self(), {:assert_ready, channel}, 10000)

      {:ok,
       %State{
         guild_id: guild_id,
         config: config
       }}
    end
  end

  def shutdown(guild_id, reason) do
    try do
      :ok = Common.player_name(guild_id) |> GenServer.stop({:shutdown, reason})
    catch
      :exit, {:noproc, _} -> {:error, :not_running}
    end
  end

  def terminate(reason, state) do
    case reason do
      {:shutdown, :voice_disconnected} ->
        Logger.warning("Player for guild #{state.guild_id} got forcibly disconnected.")
        "Lost voice connection; player terminated." |> Common.status_message(state)

      _ ->
        :noop
    end

    Voice.leave_channel(state.guild_id)
  end

  def handle_info({:assert_ready, channel}, state) do
    case Voice.ready?(state.guild_id) do
      true ->
        {:noreply, state}

      false ->
        "Failed to join channel #{channel}." |> Common.status_message(state)

        {:stop, :normal, state}
    end
  end
end
