defmodule SusBot.Consumer.VoiceStateUpdate do
  require Logger
  alias SusBot.Player

  @behaviour SusBot.ConsumerEvent

  @impl true
  def handle(event) do
    user_id = Nostrum.Cache.Me.get().id

    with {:ok, guild} <- Nostrum.Cache.GuildCache.get(event.guild_id),
         {:ok, channel_id} <- find_my_channel(guild.voice_states, user_id) do
      others =
        find_users_in_channel(guild.voice_states, channel_id)
        |> List.delete(user_id)

      case others do
        [] ->
          Logger.info("Alone in channel #{channel_id}, shutting down player.")
          Player.leave(event.guild_id)

        _ ->
          Logger.debug("users in channel: #{inspect(others)}")
      end
    else
      {:error, :not_active} ->
        if Player.leave(event.guild_id) == :ok do
          Logger.warning("Player for guild #{event.guild_id} got forcibly disconnected.")
        end
    end
  end

  defp find_my_channel(voice_states, user_id) do
    voice_states
    |> Enum.find(&(&1.user_id == user_id))
    |> then(fn
      %{channel_id: c_id} -> {:ok, c_id}
      nil -> {:error, :not_active}
    end)
  end

  defp find_users_in_channel(voice_states, channel_id) do
    voice_states
    |> Enum.filter(&(&1.channel_id == channel_id))
    |> Enum.map(& &1.user_id)
  end
end
