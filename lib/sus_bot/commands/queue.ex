defmodule SusBot.Commands.Queue do
  alias Nostrum.Struct.Interaction
  alias SusBot.Player
  alias SusBot.Queue
  alias SusBot.Queue.Entry
  alias SusBot.Media

  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description, do: "Lists tracks in queue."

  @impl true
  def type, do: :slash

  @impl true
  def command(%Interaction{} = inter) do
    case Player.queue(inter.guild_id) do
      {:ok, q} -> [content: Queue.to_list(q) |> generate_reply(), ephemeral?: true]
      {:error, :not_running} -> [content: "Not currently active.", ephemeral?: true]
    end
  end

  defp generate_reply([]), do: "Nothing is playing at the moment."

  defp generate_reply(list) do
    list
    |> Enum.map(fn
      %Entry{id: id, media: media} -> "- **#{id}:** #{describe_media(media)}"
    end)
    |> Enum.join("\n")
  end

  defp describe_media(%Media.Track{} = track), do: track.title

  defp describe_media(%Media.Playlist{} = playlist) do
    count = Enum.count(playlist.tracks)

    "*(#{count} tracks)* #{playlist.title}"
  end
end
