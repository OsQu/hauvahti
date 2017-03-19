defmodule Hauvahti.Metrics.DispatcherTest do
  use ExUnit.Case, async: true

  alias Hauvahti.Metrics.Dispatcher

  setup context do
    {:ok, dispatcher} = Dispatcher.start_link(context.test)
    {:ok, dispatcher: dispatcher}
  end

  test "dispatching metrics for new user", %{dispatcher: dispatcher} do
    Dispatcher.dispatch(dispatcher, 1, "sound=10")
    metrics = Dispatcher.metrics(dispatcher, 1)

    assert metrics == %{"sound" => [10]}
  end

  test "dispatching metrics for existing user", %{dispatcher: dispatcher} do
    Dispatcher.dispatch(dispatcher, 1, "sound=10")
    Dispatcher.dispatch(dispatcher, 1, "sound=5")

    metrics = Dispatcher.metrics(dispatcher, 1)

    assert metrics == %{"sound" => [5,10]}
  end

  test "dispatching metrics for multiple users", %{dispatcher: dispatcher} do
    Dispatcher.dispatch(dispatcher, 1, "sound=10")
    Dispatcher.dispatch(dispatcher, 2, "humidity=10")
    Dispatcher.dispatch(dispatcher, 2, "sound=5")
    Dispatcher.dispatch(dispatcher, 2, "sound=10")
    Dispatcher.dispatch(dispatcher, 1, "sound=10")

    assert Dispatcher.metrics(dispatcher, 1) == %{"sound" => [10,10]}
    assert Dispatcher.metrics(dispatcher, 2) == %{"sound" => [10,5], "humidity" => [10]}
  end
end
