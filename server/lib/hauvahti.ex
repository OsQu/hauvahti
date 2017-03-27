defmodule Hauvahti do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Hauvahti.Repo, []),
      supervisor(Hauvahti.Endpoint, []),
      worker(GenEvent, [[name: Hauvahti.Metrics.Events]]),
      worker(Hauvahti.Metrics.Store, [Hauvahti.Metrics.Store]),
      worker(Hauvahti.Metrics.Parser, [Hauvahti.Metrics.Parser, Hauvahti.Metrics.Events]),
      worker(Hauvahti.Alerts.StrategyMonitor, [Hauvahti.Alerts.StrategyMonitor, Hauvahti.Metrics.Events])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hauvahti.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Hauvahti.Endpoint.config_change(changed, removed)
    :ok
  end
end
