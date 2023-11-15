defmodule SusBot.Player.Lifecycle do
  alias Nostrum.Api, as: Discord
  alias Nostrum.Voice
  alias Nostrum.Cache.ChannelCache
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
    with {:ok, channel} <- ensure_channel_cached(channel_id) do
      Voice.join_channel(guild_id, channel_id)

      Process.send_after(self(), {:assert_ready, channel}, 10000)

      {:ok,
       %State{
         guild_id: guild_id,
         config: config
       }}
    end
  end

  def terminate(_reason, state) do
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

  # Voice requires the channel be cached,
  # and for some reason, that's not happening automatically.
  defp ensure_channel_cached(channel_id) do
    case ChannelCache.get(channel_id) do
      {:ok, channel} ->
        {:ok, channel}

      {:error, :not_found} ->
        with {:ok, channel} <- Discord.get_channel(channel_id) do
          ChannelCache.create(channel)
          {:ok, channel}
        else
          {:error, %Nostrum.Error.ApiError{status_code: 403}} -> {:error, :missing_access}
        end
    end
  end
end
