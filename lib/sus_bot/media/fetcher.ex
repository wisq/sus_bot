defmodule SusBot.Media.Fetcher do
  require Logger

  @options [
    "--flat-playlist"
  ]

  def fetch(%URI{} = uri, timeout \\ 10000) do
    uri = URI.to_string(uri)

    Task.async(fn ->
      port = open_port("yt-dlp", @options ++ ["-J", uri])

      os_pid = Port.info(port) |> Keyword.fetch!(:os_pid)
      Process.send_after(self(), {:timeout, os_pid}, timeout)

      receive_loop(port)
    end)
    |> Task.await(timeout + 1000)
    |> then(fn
      {:exited, n, json} when n in [0, 1] ->
        Jason.decode(json)

      {:exited, n, _} when n > 1 ->
        Logger.error("Fetcher exited with status #{n} accessing #{inspect(uri)}")
        {:error, :fetcher_failed}

      :timed_out ->
        Logger.warning("Fetcher timed out accessing #{inspect(uri)}")
        {:error, :fetcher_timed_out}
    end)
  end

  defp receive_loop(port, buf \\ []) do
    receive do
      {^port, {:data, data}} ->
        receive_loop(port, [data | buf])

      {^port, {:exit_status, n}} ->
        {:exited, n, Enum.reverse(buf) |> IO.iodata_to_binary()}

      {:timeout, os_pid} ->
        System.cmd("kill", ["-9", "#{os_pid}"], stderr_to_stdout: true)
        :timed_out
    end
  end

  defp find_executable(cmd) do
    case System.find_executable(cmd) do
      nil -> {:error, :fetcher_not_found}
      path when is_binary(path) -> {:ok, path}
    end
  end

  defp open_port(cmd, args) do
    {:ok, exec} = find_executable(cmd)

    Port.open({:spawn_executable, String.to_charlist(exec)}, [
      {:args, Enum.map(args, &String.to_charlist/1)},
      :exit_status,
      :binary
    ])
  end
end
