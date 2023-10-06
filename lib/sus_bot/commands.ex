defmodule SusBot.Commands do
  use SusBot.Commands.Def

  @desc "play music"
  @opts [
    %{
      name: "url",
      description: "URL to play",
      type: Nostrum.Constants.ApplicationCommandOptionType.string(),
      required: true
    }
  ]

  defcommand susplay(event, %{url: url}) do
    response = %{
      type: 4,
      data: %{
        flags: 64,
        content: "I got this URL: #{inspect(url)}"
      }
    }

    Nostrum.Api.create_interaction_response!(event, response)
  end
end
