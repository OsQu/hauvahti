defmodule Hauvahti.Metrics do
  alias Hauvahti.Metrics.{Store, Parser}

  def fetch(user) do
    Store.metrics(Store, user)
  end

  def dispatch(user, events) do
    Parser.parse(Parser, user, events)
  end
end
