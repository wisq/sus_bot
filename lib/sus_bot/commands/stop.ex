defmodule SusBot.Commands.Stop do
  alias SusBot.Player
  alias Nostrum.Struct.Interaction

  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description, do: "stop playing"

  @impl true
  def type, do: :slash

  @impl true
  def command(%Interaction{} = inter) do
    case Player.stop(inter.guild_id) do
      :ok -> [content: "Playback stopped."]
      {:error, :not_playing} -> [content: "Nothing is currently playing.", ephemeral?: true]
      {:error, :not_running} -> [content: "Not currently active.", ephemeral?: true]
    end
  end
end
