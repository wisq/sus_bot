defmodule SusBot.Commands do
  alias __MODULE__, as: C

  @commands %{
    "susplay" => C.Play,
    "susskip" => C.Skip,
    "susstop" => C.Stop,
    "susleave" => C.Leave
  }

  def commands, do: @commands
end
