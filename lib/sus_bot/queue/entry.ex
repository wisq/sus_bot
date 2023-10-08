defmodule SusBot.Queue.Entry do
  alias SusBot.Media.{Track, Playlist}
  alias Nostrum.Struct.User
  alias __MODULE__

  @enforce_keys [:media, :queue, :added_by]
  defstruct(
    id: nil,
    media: nil,
    queue: nil,
    added_by: nil
  )

  def new(%Track{} = track, %User{} = added_by) do
    %Entry{
      media: track,
      queue: [track] |> :queue.from_list(),
      added_by: added_by
    }
  end

  def new(%Playlist{} = playlist, %User{} = added_by) do
    %Entry{
      media: playlist,
      queue: playlist.tracks |> :queue.from_list(),
      added_by: added_by
    }
  end

  def pop_next(%Entry{} = entry) do
    case :queue.out(entry.queue) do
      {{:value, track}, queue} -> {track, %Entry{entry | queue: queue}}
      {:empty, _} -> :error
    end
  end
end
