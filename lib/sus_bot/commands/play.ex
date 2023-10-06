defmodule SusBot.Commands.Play do
  alias SusBot.Player
  alias Nostrum.Struct.Interaction

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
  def command(%Interaction{} = interaction) do
    [%{name: "url", value: url}] = interaction.data.options

    [
      type: {:deferred_channel_message_with_source, {&fetch/2, [url, interaction.user]}},
      ephemeral?: true
    ]
  end

  defp fetch(url, user) do
    entry = Player.Entry.fetch(url, user)

    [
      content: "Got entry: ```\n#{inspect(entry, pretty: true)}\n```"
    ]
  end
end
