import Config

config :sus_bot, SusBot.Application, start_bot: true
config :sus_bot, SusBot.HealthCheck, enabled: true, port: 8080
