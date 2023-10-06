defmodule SusBot.Consumer do
  use Nostrum.Consumer
  require Logger

  @commands SusBot.Commands.commands()

  def handle_event({:GUILD_AVAILABLE, guild, _ws_state}) do
    Logger.info("Now active on guild ##{guild.id}: #{guild.name}")

    {:ok, _} = Nostrum.Api.bulk_overwrite_guild_application_commands(guild.id, @commands)
  end

  def handle_event({:INTERACTION_CREATE, event, _ws_state}) do
    SusBot.Commands.run(event)
  end

  def handle_event({:VOICE_SPEAKING_UPDATE, event, _ws_state}) do
    event |> inspect(pretty: true) |> Logger.debug()
  end

  def handle_event({event, _, _}) do
    Logger.debug("#{event}")
    :noop
  end
end
