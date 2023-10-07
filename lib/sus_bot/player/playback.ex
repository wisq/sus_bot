defmodule SusBot.Player.Playback do
  require Logger
  alias Nostrum.Api, as: Discord
  alias Nostrum.Voice
  alias SusBot.Player.{Common, State}
  alias SusBot.Playlist
  alias SusBot.Embeds

  def wakeup(guild_id) do
    Common.cast(guild_id, :wakeup)
  end

  def handle_cast(:wakeup, state) do
    {:noreply, state, {:continue, :play_next}}
  end

  def handle_continue(:play_next, state) do
    cond do
      state.mode != :playing ->
        Logger.debug("[Voice #{state.guild_id}] Mode is #{inspect(state.mode)}")
        {:noreply, state}

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
            Discord.create_message(c_id, embeds: [Embeds.NowPlaying.generate(entry)])
            Voice.play(state.guild_id, entry.url, entry.play_type)

            {:noreply, %State{state | now_playing: entry, playlist: new_playlist}}

          :error ->
            Logger.debug("[Voice #{state.guild_id}] Empty playlist")
            {:noreply, %State{state | now_playing: nil}}
        end
    end
  end
end
