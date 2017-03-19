defmodule Hauvahti.MetricsBucket do
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def register(metrics_bucket, metrics) do
    [key, event] = parse_metrics(metrics)
    Agent.update(metrics_bucket, fn store ->
      case Map.fetch(store, key) do
        {:ok, events} -> Map.put(store, key, [event | events])
        :error -> Map.put(store, key, [event])
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

  defp parse_metrics(metrics) do
    [key, event] = String.split(metrics, "=")
    [key, String.to_integer(event)]
  end
end
