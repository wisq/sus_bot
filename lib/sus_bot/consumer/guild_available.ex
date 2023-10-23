defmodule SusBot.Consumer.GuildAvailable do
  alias Nosedrum.Storage.Dispatcher
  require Logger

  @behaviour SusBot.ConsumerEvent

  @impl true
  def handle(guild) do
    Logger.info("Now active on guild ##{guild.id}: #{guild.name}")

    case SusBot.Player.available?(guild.id) do
      true ->
        SusBot.Commands.commands()

      false ->
        Logger.warning("No player configured for #{guild.name}.")
        %{}
    end
    |> Dispatcher.bulk_overwrite_commands(guild.id)
    |> then(fn
      {:ok, cmds} ->
        Logger.info("Registered #{Enum.count(cmds)} commands on #{guild.name}.")

      {:error, _} = e ->
        inspect(e, label: "Error registering commands on #{guild.name}:")
        |> Logger.error()
    end)
  end
end
