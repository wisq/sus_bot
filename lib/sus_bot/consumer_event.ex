defmodule SusBot.ConsumerEvent do
  alias Nostrum.Struct.Message

  @callback handle(Message.t()) :: :ok | nil
end
