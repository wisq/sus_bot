defmodule SusBot.Playlist.Entry do
  alias Nostrum.Struct.User
  alias SusBot.Fetcher
  alias __MODULE__

  @enforce_keys [:title, :url, :play_type, :added_by]
  defstruct(
    id: nil,
    title: nil,
    thumbnail: nil,
    url: nil,
    play_type: nil,
    added_by: nil,
    duration: nil
  )

  def fetch(uri, %User{} = user) when is_binary(uri) do
    with {:ok, uri} <- parse_http_uri(uri),
         {:ok, data} <- Fetcher.fetch(uri),
         {:ok, play_type} <- detect_play_type(data) do
      {:ok,
       %Entry{
         title: Map.fetch!(data, "title"),
         url: Map.fetch!(data, "webpage_url"),
         thumbnail: Map.get(data, "thumbnail"),
         duration: Map.get(data, "duration"),
         play_type: play_type,
         added_by: user.username
       }}
    end
  end

  defp parse_http_uri(uri) do
    case URI.parse(uri) do
      %URI{scheme: s} = u when s in ["http", "https"] -> {:ok, u}
      _ -> {:error, "Not an HTTP(S) URI: #{inspect(uri)}"}
    end
  end

  defp detect_play_type(%{"extractor" => "generic"}), do: {:ok, :url}
  defp detect_play_type(%{"extractor" => "youtube"}), do: {:ok, :ytdl}
  defp detect_play_type(%{"extractor" => "twitch:stream"}), do: {:ok, :stream}

  defp detect_play_type(%{"extractor" => ex}) do
    {:error, "Unknown site / file format: #{inspect(ex)}"}
  end
end