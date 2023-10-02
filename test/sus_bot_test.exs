defmodule SusBotTest do
  use ExUnit.Case
  doctest SusBot

  test "greets the world" do
    assert SusBot.hello() == :world
  end
end
