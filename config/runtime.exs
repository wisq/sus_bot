import Config
alias SusBot.Secrets

unless config_env() == :test do
  config :nostrum, token: Secrets.fetch!("DISCORD_BOT_TOKEN")
end

case System.fetch_env("APP_MODE") do
  {:ok, mode} ->
    # Running inside Docker
    config :sus_bot, SusBot.Application, start_bot: mode == "bot"

  :error ->
    if config_env() == :prod, do: raise("Must set APP_MODE in production environment")
end
