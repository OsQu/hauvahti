defmodule Hauvahti.Metrics.Parser do
  use GenServer

  def start_link(name, event_channel) do
    GenServer.start_link(__MODULE__, event_channel, name: name)
  end

  def parse(server, user, events) do
    GenServer.cast(server, {:parse_event, user, events})
  end

  def handle_cast({:parse_event, user, events}, event_channel) do
    Enum.each(parse_events(events), fn ([key, value]) ->
      GenEvent.notify(event_channel, {:incoming_event, user, {key, value}})
    end)

    {:noreply, event_channel}
  end

  defp parse_events(events) when is_bitstring(events) do
    parse_events(String.split(events, ","))
  end

  defp parse_events(events) when is_list(events) do
    Enum.map(events, fn (event) ->
      [key, value] = String.split(event, "=")
      [key, String.to_integer(value)]
    end)
  end
end
