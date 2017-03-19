defmodule Hauvahti.Metrics do
  alias Hauvahti.Metrics.Store

  def fetch(user) do
    Store.metrics(Store, user)
  end

  def dispatch(user, events) do
    Store.save(Store, user, events)
  end
end
