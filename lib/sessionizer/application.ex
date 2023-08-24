defmodule Sessionizer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SessionizerWeb.Telemetry,
      # Start the Ecto repository
      Sessionizer.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Sessionizer.PubSub},
      # Start Finch
      {Finch, name: Sessionizer.Finch},
      # Start the Endpoint (http/https)
      SessionizerWeb.Endpoint,
      {Sessionizer.StudentCache, []}
      # Start a worker by calling: Sessionizer.Worker.start_link(arg)
      # {Sessionizer.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Sessionizer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SessionizerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
