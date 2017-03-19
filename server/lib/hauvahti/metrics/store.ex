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
    {:ok, %{metrics_buckets: %{}, alert_handlers: %{}}}
  end

  def handle_call({:get_metrics, user}, _from, resources) do
    {:reply, metrics_for(resources[:metrics_buckets], user), resources}
  end

  def handle_cast(
    {:store_events, user, events},
    %{metrics_buckets: metrics_buckets, alert_handlers: alert_handlers}
  ) do
    metrics_buckets = ensure_resource(metrics_buckets, user, fn ->
      {:ok, metric_bucket} = Hauvahti.Metrics.Bucket.start_link
      metric_bucket
    end)

    alert_handlers = ensure_resource(alert_handlers, user, fn ->
      :do_smth
    end)

    with parsed_events <- String.split(events, ","),
         metrics_bucket <- Map.get(metrics_buckets, user),
         alert_handler <- Map.get(alert_handlers, user)
    do
      store_events(metrics_bucket, parsed_events)
      notify_alert(alert_handler, parsed_events)
    end

    {:noreply, %{metrics_buckets: metrics_buckets, alert_handlers: alert_handlers}}
  end

  defp store_events(metrics_bucket, events) do
    Hauvahti.Metrics.Bucket.register(metrics_bucket, events)
  end

  defp notify_alert(alert, events) do

  end

  def ensure_resource(resource, user, init_fn) do
    case Map.fetch(resource, user) do
      {:ok, _} -> resource
      :error ->
        Map.put(resource, user, init_fn.())
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
