defmodule SusBot.Consumer do
  @behaviour Nostrum.Consumer
  use GenServer
  require Logger

  alias SusBot.Consumer, as: C

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  @impl true
  def handle_event({:GUILD_AVAILABLE, guild, _ws_state}) do
    C.GuildAvailable.handle(guild)
  end

  @impl true
  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    C.InteractionCreate.handle(interaction)
  end

  @impl true
  def handle_event({:VOICE_READY, event, _ws_state}) do
    C.VoiceReady.handle(event)
  end

  @impl true
  def handle_event({:VOICE_SPEAKING_UPDATE, event, _ws_state}) do
    C.VoiceSpeakingUpdate.handle(event)
  end

  @impl true
  def handle_event({:VOICE_STATE_UPDATE, event, _ws_state}) do
    C.VoiceStateUpdate.handle(event)
  end

  @impl true
  def handle_event({event, _, _}) do
    Logger.debug("#{event}")
  end
end
