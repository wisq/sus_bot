defmodule SusBot.Commands.Stop do
  alias SusBot.Player
  alias Nostrum.Struct.Interaction

  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description, do: "Stops playing music."

  @impl true
  def type, do: :slash

  @impl true
  def command(%Interaction{} = inter) do
    case Player.stop(inter.guild_id) do
      :ok -> [content: "Playback stopped."]
      {:error, :stopped} -> [content: "Nothing is currently playing.", ephemeral?: true]
      {:error, :not_running} -> [content: "Not currently active.", ephemeral?: true]
    end
  end
end
