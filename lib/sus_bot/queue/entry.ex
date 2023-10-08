defmodule SusBot.Queue.Entry do
  alias SusBot.Track
  alias Nostrum.Struct.User
  alias __MODULE__

  @enforce_keys [:tracks, :queue, :added_by]
  defstruct(
    id: nil,
    tracks: nil,
    queue: nil,
    added_by: nil
  )

  def new(%Track{} = track, %User{} = added_by), do: new([track], added_by)

  def new(tracks, %User{} = added_by) when is_list(tracks) do
    %Entry{
      tracks: tracks,
      queue: :queue.from_list(tracks),
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
