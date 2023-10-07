defmodule SusBot.Playlist do
  alias __MODULE__
  alias SusBot.Playlist.Entry

  defstruct(queue: :queue.new())

  def new, do: %Playlist{}

  defp wrap(queue) when is_tuple(queue), do: %Playlist{queue: queue}

  def append(%Playlist{} = queue, %Entry{} = entry) do
    :queue.in(entry, queue.queue)
    |> wrap()
  end

  def pop_next(%Playlist{} = queue) do
    case :queue.out(queue.queue) do
      {{:value, entry}, queue} -> {entry, wrap(queue)}
      {:empty, _} -> :error
    end
  end
end
