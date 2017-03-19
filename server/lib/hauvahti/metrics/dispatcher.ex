# NOTE: This could have been achieved also with Phoenix channels, but using
#       bare OTP constructs is more educational
defmodule Hauvahti.Metrics.Dispatcher do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  ## Client actions

  def dispatch(server, user, metrics) do
    GenServer.cast(server, {:dispatch_metrics, user, metrics})
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

  def handle_cast({:dispatch_metrics, user, metrics}, metrics_buckets) do
    metrics_buckets = ensure_metrics_bucket(metrics_buckets, user)

    metrics_buckets
    |> Map.get(user)
    |> store_metrics(metrics)

    {:noreply, metrics_buckets}
  end

  defp store_metrics(metrics_bucket, metrics) do
    Hauvahti.Metrics.Bucket.register(metrics_bucket, metrics)
  end

  defp ensure_metrics_bucket(metrics_buckets, user) do
    case Map.fetch(metrics_buckets, user) do
      {:ok, _} -> metrics_buckets
      :error ->
        {:ok, metrics_bucket} = Hauvahti.Metrics.Bucket.start_link
        Map.put(metrics_buckets, user, metrics_bucket)
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
