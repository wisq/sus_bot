defmodule SusBot.Fetcher do
  alias Porcelain.Process

  def fetch(%URI{} = uri, timeout \\ 5000) do
    with %Process{} = p <- Porcelain.spawn("yt-dlp", ["-J", URI.to_string(uri)]),
         {:ok, %{status: 0, out: json}} <- Porcelain.Process.await(p, timeout) do
      Jason.decode(json)
    else
      {:error, :timeout} -> {:error, :fetcher_timeout}
      {:error, "Command not found: " <> _} -> {:error, :fetcher_not_found}
      {:ok, %{status: n}} when n > 0 -> {:error, :fetcher_failed}
    end
    |> IO.inspect()
  end
end
