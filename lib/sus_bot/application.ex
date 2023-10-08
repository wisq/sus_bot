defmodule SusBot.Application do
  # require Logger
  use Application

  def start(_type, _args) do
    children = bot_children() ++ test_children()

    options = [strategy: :rest_for_one, name: SusBot.Supervisor]
    Supervisor.start_link(children, options)
  end

  def config(name) do
    Application.fetch_env!(:sus_bot, __MODULE__)
    |> Keyword.fetch!(name)
  end

  def bot_children() do
    if config(:start_bot) do
      [:nosedrum, :nostrum] |> Enum.each(&Application.ensure_all_started/1)

      [
        {Nosedrum.Storage.Dispatcher, name: Nosedrum.Storage.Dispatcher},
        {DynamicSupervisor, name: SusBot.Player.supervisor()},
        SusBot.Consumer
      ]
    else
      []
    end
  end

  def test_children() do
    if config(:start_test) do
      []
    else
      []
    end
  end
end
