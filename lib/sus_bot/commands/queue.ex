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
      {:ok, queue} -> [content: generate_reply(queue), ephemeral?: true]
      {:error, :not_running} -> [content: "Not currently active.", ephemeral?: true]
    end
  end

  defp generate_reply(%Queue{} = queue) do
    queue
    |> Queue.to_list()
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
