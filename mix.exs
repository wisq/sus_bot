defmodule SusBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :sus_bot,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {SusBot.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:nostrum, github: "Kraigie/nostrum", ref: "6281c99", runtime: false, override: true},
      {:nosedrum, github: "wisq/nosedrum", ref: "76494a5", runtime: false},
      {:jason, "~> 1.4"},
      # For health checks:
      {:bandit, "~> 1.1"}
    ]
  end
end
