defmodule SusBot.Player.State do
  alias SusBot.Queue

  @enforce_keys [:guild_id, :config]
  defstruct(
    guild_id: nil,
    config: nil,
    mode: :playing,
    now_playing: nil,
    next_id: 1,
    queue: Queue.new()
  )
end
