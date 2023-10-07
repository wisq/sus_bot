defmodule SusBot.Commands do
  alias __MODULE__, as: C

  @commands %{
    "susplay" => C.Play,
    "susstop" => C.Stop,
    "susleave" => C.Leave
  }

  def commands, do: @commands
end
