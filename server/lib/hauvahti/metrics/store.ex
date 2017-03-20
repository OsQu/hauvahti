# NOTE: This could have been achieved also with Phoenix channels, but using
#       bare OTP constructs is more educational
defmodule Hauvahti.Metrics.Store do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  ## Client actions

  def save(server, user, events) do
    GenServer.cast(server, {:store_events, user, events})
  end

  def metrics(server, user) do
    case GenServer.call(server, {:get_metrics, user}) do
      {:ok, metrics} -> metrics
      {:error, _ } -> nil
    end
  end

  ## Server callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get_metrics, user}, _from, metrics_buckets) do
    {:reply, metrics_for(metrics_buckets, user), metrics_buckets}
  end

  def handle_cast(
    {:store_events, user, events}, metrics_buckets
  ) do
    metrics_buckets = ensure_resources(metrics_buckets, user)

    with parsed_events <- String.split(events, ","),
         metrics_bucket <- Map.get(metrics_buckets, user)
    do
      store_events(metrics_bucket, parsed_events)
    end

    {:noreply, metrics_buckets}
  end

  defp store_events(metrics_bucket, events) do
    Hauvahti.Metrics.Bucket.register(metrics_bucket, events)
  end

  def ensure_resources(metrics_buckets, user) do
    case Map.fetch(metrics_buckets, user) do
      {:ok, _} -> metrics_buckets
      :error ->
        {:ok, metric_bucket} = Hauvahti.Metrics.Bucket.start_link
        # TODO: Attach event handler
        Map.put(metrics_buckets, user, metric_bucket)
    end
  end

  defp metrics_for(metrics_buckets, user) do
    with {:ok, metrics_bucket} <- Map.fetch(metrics_buckets, user)
    do
      {:ok, Hauvahti.Metrics.Bucket.get_all(metrics_bucket)}
    else
      :error -> {:error, "No metrics stored for user: #{user}"}
    end
  end
end
