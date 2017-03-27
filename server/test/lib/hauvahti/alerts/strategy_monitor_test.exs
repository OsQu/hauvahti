defmodule Hauvahti.Alerts.StrategyMonitorTest do
  defmodule TestListener do
    use GenEvent

    def handle_call(:error, _state) do
      raise "Error, Error!"
    end
  end

  use Hauvahti.ConnCase
  import Hauvahti.PollTimeout

  alias Hauvahti.Alerts.StrategyMonitor
  alias Hauvahti.{Repo,User,AlertStrategy}

  setup context do
    {:ok, user} = User.changeset(%User{}, %{name: "foobar", token: "abcde"}) |> Repo.insert

    strategy_changeset = AlertStrategy.changeset(
      %AlertStrategy{},
      %{type: "Hauvahti.Alerts.StrategyMonitorTest.TestListener", user_id: user.id}
    )
    strategies = Enum.map(1..2, fn(_) ->
      case Repo.insert(strategy_changeset) do
        {:ok, strategy} -> strategy
      end
    end)

    {:ok, events} = GenEvent.start_link()
    {:ok, monitor} = StrategyMonitor.start_link(context.test, events)
    {:ok,
      monitor: monitor,
      events: events,
      strategies: strategies,
      user: user
    }
  end

  test "starting event handlers for all strategies at init", %{events: events} do
    handlers = GenEvent.which_handlers(events)
    assert length(handlers) == 2
  end

  test "adding an event handler for a new strategy", %{events: events, user: user} do
    {:ok, strategy} = AlertStrategy.changeset(
      %AlertStrategy{},
      %{type: "Hauvahti.Alerts.StrategyMonitorTest.TestListener", user_id: user.id}
    ) |> Repo.insert

    StrategyMonitor.add_event_handler(events, strategy)
    handlers = GenEvent.which_handlers(events)
    Enum.each(handlers, &GenEvent.remove_handler(events, &1, []))
    assert length(handlers) == 3
  end

  @tag :capture_log
  test "re-adding the event handler when the handler dies", %{events: events} do
    [handler | _] = GenEvent.which_handlers(events)
    GenEvent.call(events, handler, :error)
    assert_timeout GenEvent.which_handlers(events) |> length == 2
  end
end
