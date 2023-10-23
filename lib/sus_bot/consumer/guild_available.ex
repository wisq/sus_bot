defmodule SusBot.Consumer.GuildAvailable do
  alias Nostrum.Api, as: Discord
  alias Nosedrum.Storage.Dispatcher
  require Logger

  @behaviour SusBot.ConsumerEvent

  @impl true
  def handle(guild) do
    Logger.info("Now active on guild ##{guild.id}: #{guild.name}")

    commands =
      case SusBot.Player.available?(guild.id) do
        true ->
          SusBot.Commands.commands()

        false ->
          Logger.warning("No player configured for #{guild.name}.")
          %{}
      end

    register_commands(commands, guild)
    cleanup_old_commands(commands, guild)
  end

  defp register_commands(commands, guild) do
    commands
    |> Enum.each(fn {name, module} ->
      Dispatcher.add_command(name, module, guild.id)
      |> log_result(:register, guild, name, module)
    end)
  end

  defp cleanup_old_commands(commands, guild) do
    command_names = commands |> Map.keys()

    {:ok, commands} = Discord.get_guild_application_commands(guild.id)

    commands
    |> Enum.each(fn %{id: id, name: name, type: type} ->
      unless name in command_names do
        Discord.delete_guild_application_command(guild.id, id)
        |> log_result(:unregister, guild, name, type)
      end
    end)
  end

  defp log_result(rval, action, guild, name, module) do
    cmd = command_name(name, module)

    case {action, rval} do
      {:register, {:ok, _}} -> Logger.debug("Registered command on #{guild.name}: #{cmd}")
      {:unregister, {:ok}} -> Logger.info("Unregistered command on #{guild.name}: #{cmd}")
      {a, e} -> inspect(e, label: "Error #{a}ing #{cmd} on #{guild.name}:") |> Logger.error()
    end

    # Delay between register events, to avoid throttle timeouts.
    Enum.random(2000..4000)
    |> Process.sleep()
  end

  defp command_name(name, module) when is_atom(module), do: cname(name, module.type())
  defp command_name(name, type) when is_integer(type), do: cname(name, type)

  defp cname(name, :slash), do: "/#{name}"
  defp cname(name, 1), do: cname(name, :slash)
end
