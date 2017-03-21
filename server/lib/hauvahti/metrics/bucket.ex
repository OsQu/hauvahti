defmodule Hauvahti.Metrics.Bucket do
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def register(metrics_bucket, {key, value}) do
    Agent.update(metrics_bucket, fn store ->
      case Map.fetch(store, key) do
        {:ok, events} -> Map.put(store, key, [value | events])
        :error -> Map.put(store, key, [value])
      end
    end)

    metrics_bucket
  end

  def get(metrics_bucket, key) do
    Agent.get(metrics_bucket, fn store -> store[key] end)
  end

  def get_all(metrics_bucket) do
    Agent.get(metrics_bucket, fn store -> store end)
  end
end
