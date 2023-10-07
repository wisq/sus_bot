defmodule SusBot.Consumer.VoiceReady do
  require Logger

  @behaviour SusBot.ConsumerEvent

  @impl true
  def handle(event) do
    SusBot.Player.wakeup(event.guild_id)
  end
end
