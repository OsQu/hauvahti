# NOTE: This could have been achieved also with Phoenix channels, but using
#       bare OTP constructs is more educational
defmodule Hauvahti.Metrics.Store do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  ## Client actions

  def save(server, user, event) do
    GenServer.cast(server, {:store_event, user, event})
  end

  def metrics(server, user) do
    case GenServer.call(server, {:get_metrics, user}) do
      {:ok, metrics} -> metrics
      {:error, _ } -> nil
    end
  end

  ## Server callbacks

  def init(:ok) do
    # TODO: Handle failures, add_mon_handler or smth?
    GenEvent.add_handler(Hauvahti.Metrics.Events, Hauvahti.Metrics.StoreListener, [])
    {:ok, %{}}
  end

  def handle_call({:get_metrics, user}, _from, metrics_buckets) do
    {:reply, metrics_for(metrics_buckets, user), metrics_buckets}
  end

  def handle_cast(
    {:store_event, user, event}, metrics_buckets
  ) do
    metrics_buckets = ensure_resources(metrics_buckets, user)

    metrics_buckets
    |> Map.get(user)
    |> store_event(event)

    {:noreply, metrics_buckets}
  end

  defp store_event(metrics_bucket, event) do
    Hauvahti.Metrics.Bucket.register(metrics_bucket, event)
  end

  def ensure_resources(metrics_buckets, user) do
    case Map.fetch(metrics_buckets, user) do
      {:ok, _} -> metrics_buckets
      :error ->
        {:ok, metric_bucket} = Hauvahti.Metrics.Bucket.start_link
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
