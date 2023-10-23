defmodule SusBot.Commands do
  alias __MODULE__, as: C

  @commands %{
    "susplay" => C.Play,
    "susskip" => C.Skip,
    "susstop" => C.Stop,
    "susleave" => C.Leave,
    "susqueue" => C.Queue,
    "susdelete" => C.Delete
  }

  def commands, do: @commands
end
