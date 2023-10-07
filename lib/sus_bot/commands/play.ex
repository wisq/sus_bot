defmodule SusBot.Commands.Play do
  alias SusBot.Player
  alias Nostrum.Struct.Interaction
  alias Nostrum.Cache.GuildCache

  @behaviour Nosedrum.ApplicationCommand

  @impl true
  def description, do: "Add a URL to the queue."

  @impl true
  def type, do: :slash

  @impl true
  def options() do
    [
      %{
        name: "url",
        description: "URL to play.  Supports YouTube, Twitch, direct links, etc.",
        type: :string,
        required: true
      }
    ]
  end

  @impl true
  def command(%Interaction{} = inter) do
    [%{name: "url", value: url}] = inter.data.options

    with {:ok, channel_id} <- find_voice_channel_id(inter.guild_id, inter.user.id) do
      [
        type:
          {:deferred_channel_message_with_source,
           {&queue/4,
            [
              url,
              inter.guild_id,
              inter.user,
              channel_id
            ]}},
        ephemeral?: true
      ]
    end
  end

  defp find_voice_channel_id(guild_id, user_id) do
    with {:ok, guild} <- GuildCache.get(guild_id) do
      case guild.voice_states |> Enum.find(fn vs -> vs.user_id == user_id end) do
        %{channel_id: id} -> {:ok, id}
        nil -> [content: "You must be in a voice channel to use this command.", ephemeral?: true]
      end
    end
  end

  defp queue(url, guild_id, user, channel_id) do
    rval =
      with {:ok, entry} <- Player.Entry.fetch(url, user) do
        Player.append(guild_id, entry, channel_id)
      end

    [
      content: "```\n#{inspect(rval, pretty: true)}\n```"
    ]
  end
end
