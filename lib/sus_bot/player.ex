defmodule SusBot.Player do
  use GenServer

  defmodule Config do
    @enforce_keys [:status_channel]
    defstruct(status_channel: nil)

    def parse(enum) do
      enum |> Map.new(&from_config/1)
    end

    defp from_config({guild_id, fields}) when is_integer(guild_id) do
      {guild_id, struct!(__MODULE__, fields)}
    end
  end

  @configs Application.compile_env(:sus_bot, __MODULE__, []) |> Config.parse()

  def available?(guild_id), do: Map.has_key?(@configs, guild_id)

  @impl true
  def init(_), do: {:ok, nil}
end
