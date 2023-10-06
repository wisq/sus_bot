defmodule SusBot.Consumer.InteractionCreate do
  alias Nosedrum.Storage.Dispatcher
  require Logger

  @behaviour SusBot.ConsumerEvent

  @impl true
  def handle(interaction) do
    Dispatcher.handle_interaction(interaction)
  end
end
