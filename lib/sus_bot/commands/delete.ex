defmodule SusBot.Commands.Delete do
  alias Nostrum.Struct.Interaction

  alias SusBot.Player
  alias SusBot.Embeds

  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description, do: "Delete a track from the queue."

  @impl true
  def type, do: :slash

  @impl true
  def options() do
    [
      %{
        name: "id",
        description: "ID of track to delete (from `/queue` command).",
        type: :integer,
        required: true
      }
    ]
  end

  @impl true
  def command(%Interaction{} = inter) do
    [%{name: "id", value: entry_id}] = inter.data.options

    case Player.delete(inter.guild_id, entry_id) do
      {:ok, entry} ->
        [embeds: [Embeds.Deleted.generate(entry)]]

      {:error, :not_found} ->
        [content: "Track `#{inspect(entry_id)}` not found.", ephemeral?: true]

      {:error, :not_running} ->
        [content: "Not currently active.", ephemeral?: true]
    end
  end
end
