defmodule SusBot.Commands.Skip do
  alias SusBot.Player
  alias Nostrum.Struct.Interaction

  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description, do: "Skips the current track."

  @impl true
  def type, do: :slash

  @impl true
  def command(%Interaction{} = inter) do
    case Player.skip(inter.guild_id) do
      :ok -> [content: "Track skipped."]
      {:error, :stopped} -> [content: "Nothing is currently playing.", ephemeral?: true]
      {:error, :not_running} -> [content: "Not currently active.", ephemeral?: true]
    end
  end
end
