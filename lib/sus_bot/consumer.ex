defmodule SusBot.Consumer do
  use Nostrum.Consumer
  require Logger

  alias SusBot.Consumer.{
    GuildAvailable,
    InteractionCreate
    # VoiceSpeakingUpdate
  }

  @impl true
  def handle_event({:GUILD_AVAILABLE, guild, _ws_state}) do
    GuildAvailable.handle(guild)
  end

  @impl true
  def handle_event({:INTERACTION_CREATE, interaction, _ws_state}) do
    InteractionCreate.handle(interaction)
  end

  @impl true
  def handle_event({:VOICE_SPEAKING_UPDATE, event, _ws_state}) do
    event |> inspect(pretty: true) |> Logger.debug()
  end

  @impl true
  def handle_event({event, _, _}) do
    Logger.debug("#{event}")
  end
end
