import Config

config :sus_bot, SusBot.Application, start_test: false

config :logger, :console, format: "$date $time [$level] $message\n"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
