defmodule Hauvahti.Metrics.ParserTest do
  use ExUnit.Case, async: true

  alias Hauvahti.Metrics.Parser

  defmodule Listener do
    use GenEvent

    def handle_event(msg, test_pid) do
      send(test_pid, msg)
      {:ok, test_pid}
    end
  end

  setup context do
    {:ok, channel} = GenEvent.start_link()
    GenEvent.add_handler(channel, Listener, self())

    {:ok, parser} = Parser.start_link(context.test, channel)
    {:ok, parser: parser}
  end

  test "notifying Hauvahti.Metrics.Events with parsed events", %{parser: parser} do
    Parser.parse(parser, 1, "volume=10")
    assert_receive {:incoming_event, 1, {"volume", 10}}
  end

  test "parsing multiple events from same user", %{parser: parser} do
    Parser.parse(parser, 1, "volume=10,volume=20")
    assert_receive {:incoming_event, 1, {"volume", 10}}
    assert_receive {:incoming_event, 1, {"volume", 20}}
  end

  test "parsing multiple events from many users", %{parser: parser} do
    Parser.parse(parser, 1, "volume=10,volume=20")
    Parser.parse(parser, 2, "volume=30")
    Parser.parse(parser, 1, "volume=40")

    assert_receive {:incoming_event, 1, {"volume", 10}}
    assert_receive {:incoming_event, 1, {"volume", 20}}
    assert_receive {:incoming_event, 1, {"volume", 40}}
    assert_receive {:incoming_event, 2, {"volume", 30}}
  end
end
