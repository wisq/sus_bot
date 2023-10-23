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

  def prepend(%Queue{q: q}, %Entry{} = entry) do
    :queue.in_r(entry, q)
    |> wrap()
  end

  def to_list(%Queue{q: q}) do
    :queue.to_list(q)
  end

  def pop_next(%Queue{q: q}) do
    case :queue.out(q) do
      {{:value, entry}, q} -> {entry, wrap(q)}
      {:empty, _} -> :error
    end
  end

  def pop(%Queue{q: q}, entry_id) when is_integer(entry_id) do
    case q |> :queue.to_list() |> Enum.find(&(&1.id == entry_id)) do
      %Entry{} = entry -> {entry, :queue.delete(entry, q) |> wrap()}
      nil -> :error
    end
  end
end
