defmodule Rms.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Rms.Repo,
      # Start the Telemetry supervisor
      RmsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Rms.PubSub},
      # Start the Endpoint (http/https)
      RmsWeb.Endpoint,
      # Start a worker by calling: Rms.Worker.start_link(arg)
      # {Rms.Worker, arg}

      {Rms.Scheduler, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rms.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RmsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
