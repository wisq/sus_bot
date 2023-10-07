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
    ensure_channel_cached(channel_id)
    Voice.join_channel(guild_id, channel_id)

    {:ok,
     %State{
       guild_id: guild_id,
       config: config
     }}
  end

  def terminate(_reason, state) do
    Voice.leave_channel(state.guild_id)
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
