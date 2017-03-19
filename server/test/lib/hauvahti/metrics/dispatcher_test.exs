defmodule Hauvahti.Metrics.DispatcherTest do
  use ExUnit.Case, async: true

  alias Hauvahti.Metrics.Dispatcher

  setup context do
    {:ok, dispatcher} = Dispatcher.start_link(context.test)
    {:ok, dispatcher: dispatcher, user: %Hauvahti.User{id: 1}}
  end

  test "dispatching metrics for new user", %{dispatcher: dispatcher, user: user} do
    Dispatcher.dispatch(dispatcher, user.id, "sound=10")
    metrics = Dispatcher.metrics(dispatcher, user.id)

    assert metrics == %{"sound" => [10]}
  end

  test "dispatching metrics for existing user", %{dispatcher: dispatcher, user: user} do
    Dispatcher.dispatch(dispatcher, user.id, "sound=10")
    Dispatcher.dispatch(dispatcher, user.id, "sound=5")

    metrics = Dispatcher.metrics(dispatcher, user.id)

    assert metrics == %{"sound" => [5,10]}

  end
end
