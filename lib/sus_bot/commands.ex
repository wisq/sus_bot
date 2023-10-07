defmodule SusBot.Commands do
  alias __MODULE__, as: C

  @commands %{
    "play" => C.Play,
    "stop" => C.Stop
  }

  def commands, do: @commands
end
