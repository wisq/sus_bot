import Config

config :sus_bot, SusBot.Application, start_bot: false, start_test: true
config :nostrum, token: nil

# Print only warnings and errors during test
config :logger, level: :warning
