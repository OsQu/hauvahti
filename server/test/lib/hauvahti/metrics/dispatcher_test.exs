defmodule Hauvahti.Metrics.DispatcherTest do
  use ExUnit.Case, async: true

  alias Hauvahti.Metrics.Dispatcher

  setup do
    {:ok, dispatcher} = Dispatcher.start_link
    {:ok, dispatcher: dispatcher, user: %Hauvahti.User{id: 1}}
  end

  test "dispatching metrics for user",
    %{dispatcher: dispatcher, user: user} do
    Dispatcher.dispatch(dispatcher, user.id, "sound=10")
    metrics = Dispatcher.metrics(dispatcher, user.id)

    assert metrics == %{"sound" => [10]}
  end
end
