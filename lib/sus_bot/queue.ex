defmodule SusBot.Queue do
  alias __MODULE__
  alias SusBot.Queue.Entry

  defstruct(q: :queue.new())

  def new, do: %Queue{}

  defp wrap({_, _} = queue), do: %Queue{q: queue}

  def append(%Queue{q: q}, %Entry{} = entry) do
    :queue.in(entry, q)
    |> wrap()
  end

  def pop_next(%Queue{q: q}) do
    case :queue.out(q) do
      {{:value, entry}, q} -> {entry, wrap(q)}
      {:empty, _} -> :error
    end
  end
end
