defmodule SusBot.Player.Entry do
  alias Nostrum.Struct.User
  alias __MODULE__

  @enforce_keys [:title, :url, :added_by]
  defstruct(
    id: nil,
    title: nil,
    thumbnail: nil,
    url: nil,
    added_by: nil
  )

  def fetch(uri, %User{} = user) when is_binary(uri) do
    with {:ok, uri} <- parse_http_uri(uri),
         {:ok, data} <- yt_dlp(uri) do
      {:ok,
       %Entry{
         title: Map.fetch!(data, "title"),
         thumbnail: Map.get(data, "thumbnail"),
         url: Map.fetch!(data, "webpage_url"),
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

  defp yt_dlp(%URI{} = uri) do
    case System.cmd("yt-dlp", ["-J", URI.to_string(uri)]) do
      {json, 0} -> Poison.decode(json)
      {output, _} -> {:error, output}
    end
  end
end
