defmodule SusBot.Fetcher do
  def fetch(%URI{} = uri, timeout \\ 10000) do
    port = open_port("yt-dlp", ["-J", URI.to_string(uri)])
    os_pid = Port.info(port) |> Keyword.fetch!(:os_pid)

    spawn_link(fn ->
      Process.sleep(timeout)
      System.cmd("kill", ["#{os_pid}"], stderr_to_stdout: true)
      Process.sleep(1000)
      System.cmd("kill", ["-9", "#{os_pid}"], stderr_to_stdout: true)
    end)

    case receive_loop(port, []) do
      {0, json} -> Jason.decode(json)
      # got sigterm
      {143, _} -> {:error, :fetcher_timeout}
      # got sigkill
      {137, _} -> {:error, :fetcher_timeout}
      # non-zero exit status
      {n, _} when n > 0 -> {:error, :fetcher_failed}
    end
  end

  defp receive_loop(port, buf) do
    receive do
      {^port, {:data, data}} -> receive_loop(port, [data | buf])
      {^port, {:exit_status, n}} -> {n, Enum.reverse(buf) |> IO.iodata_to_binary()}
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
