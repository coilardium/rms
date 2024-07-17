defmodule Rms.MixProject do
  use Mix.Project

  def project do
    [
      app: :rms,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Rms.Application, []},
      extra_applications: [:logger, :runtime_tools, :logger_file_backend]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.7"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:tds, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:cachex, "~> 2.0"},
      {:timex, "~> 3.7"},
      {:atomic_map, "~> 0.8"},
      {:pipe_to, "~> 0.2"},
      {:bamboo, "~> 1.3"},
      {:bamboo_smtp, "~> 2.1.0"},
      {:decimal, "~> 1.9"},
      {:scrivener, "~> 2.0"},
      {:scrivener_ecto, "~> 2.7", override: true},
      {:quantum, "~> 2.2.7"},
      {:poison, "~> 3.1"},
      {:logger_file_backend, "~> 0.0.10"},
      {:pdf_generator, "~> 0.6.2"},
      {:bbmustache, github: "soranoba/bbmustache"},
      {:elixlsx, "~> 0.4.2"},
      {:number, "~> 0.5.7"},
      {:xlsxir, "~> 1.6.2"},
      {:csv, "~>2.3"},
      {:endon, "~> 1.0"},
      {:rename_project, "~> 0.1.0"},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
