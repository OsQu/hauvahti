defmodule Hauvahti.Metrics.Alerts do
  use GenEvent

  def init([]) do
  end

  def handle_event({:incoming_event, user, events}) do
    IO.puts "Got event for #{@user}"
    IO.inspect events
  end
end
