defmodule SusBot.Queue do
  alias __MODULE__
  alias SusBot.Queue.Entry

  defstruct(queue: :queue.new())

  def new, do: %Queue{}

  defp wrap(queue) when is_tuple(queue), do: %Queue{queue: queue}

  def append(%Queue{} = queue, %Entry{} = entry) do
    :queue.in(entry, queue.queue)
    |> wrap()
  end

  def pop_next(%Queue{} = queue) do
    case :queue.out(queue.queue) do
      {{:value, entry}, queue} -> {entry, wrap(queue)}
      {:empty, _} -> :error
    end
  end
end
