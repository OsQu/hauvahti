defmodule Hauvahti.Metrics.StoreListener do
  use GenEvent

  alias Hauvahti.Metrics.Store

  def handle_event({:incoming_event, user, event}, state) do
    Store.save(Store, user, event)
    {:ok, state}
  end
end
