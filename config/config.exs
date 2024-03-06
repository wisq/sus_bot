import Config

config :sus_bot, SusBot.Application, start_test: false
config :sus_bot, SusBot.HealthCheck, enabled: false

config :sus_bot, SusBot.Player, %{
  261_357_848_934_612_992 => [
    status_channel: 543_359_278_971_617_281
  ],
  879_774_216_948_420_658 => [
    status_channel: 960_046_204_266_348_604
  ]
}

config :logger, :console, format: "$date $time [$level] $message\n"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
