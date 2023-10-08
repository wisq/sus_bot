defmodule SusBot.Player.Playback do
  require Logger
  alias Nostrum.Api, as: Discord
  alias Nostrum.Voice
  alias SusBot.Player.{Common, State}
  alias SusBot.Queue
  alias SusBot.Queue.Entry
  alias SusBot.Embeds
  alias SusBot.Media.Track

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
        {track, state} = next_track(state)

        case track do
          %Track{} ->
            Logger.debug("[Voice #{state.guild_id}] Playing #{inspect(track, pretty: true)}")

            c_id = state.config.status_channel
            embed = Embeds.NowPlaying.generate(state.now_playing, track)
            Discord.create_message(c_id, embeds: [embed])

            Voice.play(state.guild_id, track.url, track.play_type)

            {:noreply, state}

          :empty ->
            Logger.debug("[Voice #{state.guild_id}] Empty queue")
            {:noreply, state}
        end
    end
  end

  defp next_track(%State{now_playing: %Entry{} = entry} = state) do
    case Entry.pop_next(entry) do
      {track, new_entry} ->
        {track, %State{state | now_playing: new_entry}}

      :error ->
        %State{state | now_playing: nil} |> next_track()
    end
  end

  defp next_track(%State{now_playing: nil} = state) do
    case Queue.pop_next(state.queue) do
      {entry, new_queue} ->
        %State{state | now_playing: entry, queue: new_queue}
        |> next_track()

      :error ->
        {:empty, state}
    end
  end
end
