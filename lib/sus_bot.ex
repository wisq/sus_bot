defmodule SusBot do
  def token do
    Application.fetch_env!(:sus_bot, :token)
    |> IO.inspect()
  end
end
