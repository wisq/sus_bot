defmodule SusBot.Commands.Play do
  alias Nostrum.Struct.Interaction
  alias Nostrum.Cache.GuildCache

  alias SusBot.Player
  alias SusBot.Track
  alias SusBot.Embeds

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
      callback = {&queue/4, [url, inter.guild_id, inter.user, channel_id]}
      [type: {:deferred_channel_message_with_source, callback}]
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
    with {:ok, uri} <- parse_http_uri(url),
         {:ok, json} <- Track.Fetcher.fetch(uri),
         {:ok, tracks} <- Track.Decoder.decode(json),
         {:ok, queued} <- Player.append(guild_id, channel_id, tracks, user) do
      [embeds: [Embeds.Queued.generate(queued)]]
    else
      e -> [content: "```\n#{inspect(e, pretty: true)}\n```"]
    end
  end

  defp parse_http_uri(url) do
    case URI.parse(url) do
      %URI{scheme: s} = u when s in ["http", "https"] -> {:ok, u}
      _ -> {:error, "Not an HTTP(S) URI: #{inspect(url)}"}
    end
  end
end
