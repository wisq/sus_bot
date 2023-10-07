defmodule SusBot.Consumer.VoiceSpeakingUpdate do
  require Logger

  @behaviour SusBot.ConsumerEvent

  @impl true
  def handle(event) do
    if event.speaking == false do
      SusBot.Player.wakeup(event.guild_id)
    end
  end
end
