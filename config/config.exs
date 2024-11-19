# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Email Config
config :rms, Rms.Emails.Mailer,
  adapter: Bamboo.SMTPAdapter,
  # smtp.office365.com
  server: "smtp.gmail.com",
  port: 587,
  # or {:system, "SMTP_USERNAME"}
  username: "",
  # or {:system, "SMTP_PASSWORD"}
  password: "Password123$",
  # can be `:always` or `:never`
  tls: :if_available,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  # can be `true`
  ssl: false,
  retries: 2

#Pdf Generator
# config :pdf_generator,
#     wkhtml_path: "/usr/local/bin/wkhtmltopdf"

# adapter: Bamboo.SMTPAdapter,
# server: "smtp.gmail.com", #smtp.office365.com
# port: 587,
# # or {:system, "SMTP_USERNAME"}
# username: "mfulajohn360@gmail.com",
# # or {:system, "SMTP_PASSWORD"}
# password: "mfula@360",
# # can be `:always` or `:never`
# tls: :if_available,
# allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
# # can be `true`
# ssl: false,
# retries: 2

# Pdf Generator
# config :pdf_generator,
#     wkhtml_path: "/usr/local/bin/wkhtmltopdf"

config :rms,
  ecto_repos: [Rms.Repo]

config :endon,
  repo: Rms.Repo

# Application logs
config :logger,
  backends: [:console, {LoggerFileBackend, :info}, {LoggerFileBackend, :error}],
  format: "[$level] $message\n"

config :logger, :info,
  path: "/home/rmsuser/rms_uat/app_logs/#{Date.utc_today().year}/#{Date.utc_today().month}/#{Date.utc_today()}/info.log",
  level: :info,
  colors: [enabled: true]

config :logger, :error,
  path: "/home/rmsuser/rms_uat/app_logs/#{Date.utc_today().year}/#{Date.utc_today().month}/#{Date.utc_today()}/error.log",
  level: :error,
  colors: [enabled: true]

# quantum jobs config
config :logger,
  level: :debug,
  colors: [enabled: true]

config :rms, Rms.Scheduler,
  overlap: false,
  timeout: 3_620_000,
  timezone: "Africa/Cairo",
  jobs: [
    # wagon_tracking: [
    #   schedule: "00 12 * * *",
    #   # schedule: "@weekly",
    #   task: {Rms.Workers.InterchangeAccumulativeDays, :update_wagon_days_at_station, []}
    # ],
    # wagon_mvt_status_update: [
    #   schedule: "00 12 * * *",
    #   task: {RmsWeb.WagonTrackingController, :update_wagon_mvt_status, []}
    # ],
    # interchange_accumulative_days: [
    #   # schedule: {:extended, "*/20"},
    #   schedule: "30 12 * * * *",
    #   # schedule: "@weekly",
    #   task: {Rms.Workers.InterchangeAccumulativeDays, :wagons_on_hire, []}
    # ],
    # wagons: [
    #   # schedule: {:extended, "*/20"},
    #   schedule: "54 16 * * * *",
    #   # schedule: "@weekly",
    #   task: {RmsWeb.WagonTrackingController, :create_wagon_log, []}
    # ],
    # auxiliary_on_hire: [
    #   # schedule: {:extended, "*/20"},
    #   schedule: "13 12 * * * *",
    #   # schedule: "@weekly",
    #   task: {Rms.Workers.InterchangeAccumulativeDays, :auxiliary_on_hire, []}
    # ]
  ]

# Configures the endpoint
config :rms, RmsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "fZYIAExPG+jB475D5J2RQ4dGbIWSCVC7bQ2s0AekSGYOz1a3rnLv3ZH3fKTU5c/n",
  render_errors: [view: RmsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Rms.PubSub,
  live_view: [signing_salt: "3Isrj9jL"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
