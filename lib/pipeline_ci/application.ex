defmodule PipelineCi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PipelineCiWeb.Telemetry,
      PipelineCi.Repo,
      {DNSCluster, query: Application.get_env(:pipeline_ci, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PipelineCi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PipelineCi.Finch},
      # Start a worker by calling: PipelineCi.Worker.start_link(arg)
      # {PipelineCi.Worker, arg},
      # Start to serve requests, typically the last entry
      PipelineCiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PipelineCi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PipelineCiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
