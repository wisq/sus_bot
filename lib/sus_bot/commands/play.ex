defmodule SusBot.Commands.Play do
  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description, do: "play music"

  @impl true
  def type, do: :slash

  @impl true
  def options() do
    [
      %{
        name: "url",
        description: "URL to play",
        type: :string,
        required: true
      }
    ]
  end

  @impl true
  def command(interaction) do
    [%{name: "url", value: url}] = interaction.data.options

    [
      content: "Got URL: #{inspect(url)}",
      ephemeral?: true
    ]
  end
end
