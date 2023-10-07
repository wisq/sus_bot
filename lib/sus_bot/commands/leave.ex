defmodule SusBot.Commands.Leave do
  alias SusBot.Player
  alias Nostrum.Struct.Interaction

  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description, do: "Stops playback and leaves the voice channel."

  @impl true
  def type, do: :slash

  @impl true
  def command(%Interaction{} = inter) do
    case Player.leave(inter.guild_id) do
      :ok -> [content: "Player terminated."]
      {:error, :not_running} -> [content: "Not currently active.", ephemeral?: true]
    end
  end
end
