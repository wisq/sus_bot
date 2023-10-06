defmodule SusBot.Commands do
  alias __MODULE__, as: C

  @commands %{
    "susplay" => C.Play
  }

  def commands, do: @commands
end
