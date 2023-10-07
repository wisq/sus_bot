defmodule SusBot.Commands do
  alias __MODULE__, as: C

  @commands %{
    "play" => C.Play,
    "stop" => C.Stop,
    "leave" => C.Leave
  }

  def commands, do: @commands
end
