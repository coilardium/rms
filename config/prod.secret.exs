# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
# use Mix.Config
import Config

# database_url =
#   System.get_env("DATABASE_URL") ||
#     raise """
#     environment variable DATABASE_URL is missing.
#     For example: ecto://USER:PASS@HOST/DATABASE
#     """

# config :rms, Rms.Repo,
#   # ssl: true,
#   url: database_url,
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# secret_key_base =
#   System.get_env("SECRET_KEY_BASE") ||
#     raise """
#     environment variable SECRET_KEY_BASE is missing.
#     You can generate one by calling: mix phx.gen.secret
#     """

config :rms, RmsWeb.Endpoint,
  # http: [
  #   port: String.to_integer(System.get_env("PORT") || "4000"),
  #   transport_options: [socket_opts: [:inet6]]
  # ],
  secret_key_base: "4vgJDOH7oYHLdq3A67qeRfr0tiUNsSotrDl6+nXDWclp23zGYpFUGvpnvJGPMM8Y"

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :rms, RmsWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.

config :rms, Rms.Repo,
  username: "sa",
  hostname: "95.179.223.128",
  password: "Qwerty12",
  database: "rms_uat",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
