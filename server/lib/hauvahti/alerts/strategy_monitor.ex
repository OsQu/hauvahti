defmodule Hauvahti.Alerts.StrategyMonitor do
  use GenServer

  alias Hauvahti.{Repo, AlertStrategy}

  def start_link(name, events_channel) do
    GenServer.start_link(__MODULE__, events_channel, name: name)
  end

  def init(events_channel) do
    AlertStrategy
    |> Repo.all
    |> Enum.each(&add_event_handler(events_channel, &1))
    {:ok, [events_channel: events_channel]}
  end

  def add_event_handler(events_channel, %AlertStrategy{} = strategy) do
    add_event_handler(events_channel, strategy_to_event_handler(strategy))
  end

  def add_event_handler(events_channel, event_handler) do
    GenEvent.add_mon_handler(
      events_channel,
      event_handler,
      []
    )
  end

  defp strategy_to_event_handler(strategy) do
    {String.to_atom("Elixir.#{strategy.type}"), strategy.id}
  end

  # Ignore normal removals
  def handle_info({:gen_event_EXIT, _handler, :normal}, state), do: {:noreply, state}

  def handle_info({:gen_event_EXIT, handler, _reason}, [events_channel: events_channel] = state) do
    add_event_handler(events_channel, handler)
    {:noreply, state}
  end
end
