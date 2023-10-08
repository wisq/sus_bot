defmodule SusBot.Track.Decoder do
  alias SusBot.Track

  def decode(%{} = data) do
    with {:ok, play_type} <- detect_play_type(data) do
      case Map.fetch!(data, "_type") do
        "playlist" -> decode_playlist(data, play_type)
        "video" -> decode_video(data, play_type)
      end
    end
  end

  defp decode_video(data, play_type) do
    with {:ok, title} <- map_fetch(data, "title"),
         {:ok, url} <- map_fetch(data, ["webpage_url", "url"]) do
      {:ok,
       %Track{
         title: title,
         url: url,
         thumbnail: best_thumbnail(data),
         duration: Map.get(data, "duration"),
         play_type: play_type
       }}
    end
  end

  defp decode_playlist(data, play_type) do
    with {:ok, title} <- map_fetch(data, "title"),
         {:ok, description} <- map_fetch(data, "description"),
         {:ok, url} <- map_fetch(data, "webpage_url"),
         {:ok, entries} <- map_fetch(data, "entries"),
         {:ok, tracks} <- entries |> enum_map(&decode_video(&1, play_type)) do
      {:ok,
       %Playlist{
         title: title,
         url: url,
         thumbnail: best_thumbnail(data),
         tracks: tracks
       }}
    end
  end

  defp map_fetch(%{} = map, fields) when is_list(fields) do
    fields
    |> Enum.reduce_while(nil, fn field, _acc ->
      case Map.fetch(map, field) do
        {:ok, value} -> {:halt, {:ok, value}}
        :error -> {:cont, :error}
      end
    end)
    |> then(fn
      {:ok, _} = r -> r
      :error -> {:error, "Required fields not found: #{inspect(fields)}"}
    end)
  end

  defp map_fetch(%{} = map, field) when is_binary(field) do
    case Map.fetch(map, field) do
      {:ok, _} = r -> r
      :error -> {:error, "Required field not found: #{inspect(field)}"}
    end
  end

  defp enum_map(enum, fun) do
    enum
    # see https://github.com/yt-dlp/yt-dlp/issues/8206
    |> Enum.reject(&is_nil/1)
    |> Enum.with_index()
    |> Enum.reduce_while([], fn {elem, index}, acc ->
      case fun.(elem) do
        {:ok, value} -> {:cont, [value | acc]}
        {:error, err} -> {:halt, {:error, index, err}}
      end
    end)
    |> then(fn
      list when is_list(list) -> {:ok, Enum.reverse(list)}
      {:error, _, _} = e -> e
    end)
  end

  defp best_thumbnail(%{"thumbnail" => url}) when is_binary(url), do: url

  defp best_thumbnail(%{"thumbnails" => thumbs}) when is_list(thumbs) do
    thumbs
    |> Enum.max_by(fn %{"height" => h, "width" => w} -> h * w end)
    |> Map.fetch!("url")
  end

  defp detect_play_type(%{"extractor" => "generic"}), do: {:ok, :url}
  defp detect_play_type(%{"extractor" => "youtube"}), do: {:ok, :ytdl}
  defp detect_play_type(%{"extractor" => "youtube:tab"}), do: {:ok, :ytdl}
  defp detect_play_type(%{"extractor" => "twitch:stream"}), do: {:ok, :stream}

  defp detect_play_type(%{"extractor" => ex}) do
    {:error, "Unknown site / file format: #{inspect(ex)}"}
  end
end
