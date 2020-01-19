defmodule Bayaq.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Bayaq.Repo,
      # Start the endpoint when the application starts
      BayaqWeb.Endpoint
      # Starts a worker by calling: Bayaq.Worker.start_link(arg)
      # {Bayaq.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bayaq.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BayaqWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
