defmodule Hauvahti.Metrics.Bucket do
  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def register(metrics_bucket, metrics) when is_bitstring(metrics) do
    register(metrics_bucket, String.split(metrics, ","))
    metrics_bucket
  end

  def register(metrics_bucket, metrics) when is_list(metrics) do
    for metric <- metrics, do: register_event(metrics_bucket, parse_metric(metric))
    metrics_bucket
  end

  def register(metrics_bucket, nil), do: metrics_bucket

  def get(metrics_bucket, key) do
    Agent.get(metrics_bucket, fn store -> store[key] end)
  end

  def get_all(metrics_bucket) do
    Agent.get(metrics_bucket, fn store -> store end)
  end

  defp parse_metric(metrics) do
    [key, event] = String.split(metrics, "=")
    [key, String.to_integer(event)]
  end

  defp register_event(metrics_bucket, [key, event]) do
    Agent.update(metrics_bucket, fn store ->
      case Map.fetch(store, key) do
        {:ok, events} -> Map.put(store, key, [event | events])
        :error -> Map.put(store, key, [event])
      end
    end)
  end
end
