defmodule Hauvahti.MetricsDispatcherTest do
  use ExUnit.Case, async: true

  alias Hauvahti.MetricsDispatcher

  setup do
    {:ok, dispatcher} = Hauvahti.MetricsDispatcher.start_link
    {:ok, dispatcher: dispatcher, user: %Hauvahti.User{id: 1}}
  end

  test "dispatching metrics for user",
    %{dispatcher: dispatcher, user: user} do
    MetricsDispatcher.dispatch(dispatcher, user.id, "sound=10")
    metrics = MetricsDispatcher.metrics(dispatcher, user.id)

    assert metrics == %{"sound" => [10]}
  end
end
