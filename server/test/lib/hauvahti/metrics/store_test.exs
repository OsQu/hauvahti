defmodule Hauvahti.Metrics.StoreTest do
  use ExUnit.Case, async: true

  alias Hauvahti.Metrics.Store

  setup context do
    {:ok, store} = Store.start_link(context.test)
    {:ok, store: store}
  end

  test "dispatching metrics for new user", %{store: store} do
    Store.save(store, 1, {"sound", 10})
    metrics = Store.metrics(store, 1)

    assert metrics == %{"sound" => [10]}
  end

  test "dispatching metrics for existing user", %{store: store} do
    Store.save(store, 1, {"sound", 10})
    Store.save(store, 1, {"sound", 5})
    assert Store.metrics(store, 1) == %{"sound" => [5,10]}
  end

  test "dispatching metrics for multiple users", %{store: store} do
    Store.save(store, 1, {"sound", 10})
    Store.save(store, 2, {"humidity", 10})
    Store.save(store, 2, {"sound", 5})
    Store.save(store, 2, {"sound", 10})
    Store.save(store, 1, {"sound", 10})

    assert Store.metrics(store, 1) == %{"sound" => [10,10]}
    assert Store.metrics(store, 2) == %{"sound" => [10,5], "humidity" => [10]}
  end
end
