defmodule Hauvahti.MetricsBucketTest do
  use ExUnit.Case, async: true

  alias Hauvahti.MetricsBucket

  setup do
    {:ok, bucket} = MetricsBucket.start_link
    {:ok, bucket: bucket}
  end

  test "registering events for new metric type", %{bucket: bucket} do
    returned_events = bucket
    |> MetricsBucket.register("sound=10")
    |> MetricsBucket.get("sound")

    assert returned_events == [10]
  end

  test "registering events for existing metrics type", %{bucket: bucket} do
    bucket
    |> MetricsBucket.register("sound=10")
    |> MetricsBucket.register("sound=20")
    |> MetricsBucket.register("sound=5")

    returned_events = MetricsBucket.get(bucket, "sound")
    assert returned_events == [5,20,10]
  end

  test "fetching events for non-existing metrics type", %{bucket: bucket} do
    returned_events = MetricsBucket.get(bucket, "foobar")
    assert returned_events == nil
  end

  test "fetching all events", %{bucket: bucket} do
    bucket
    |> MetricsBucket.register("sound=10")
    |> MetricsBucket.register("humidness=5")
    |> MetricsBucket.register("sound=8")

    all_events = MetricsBucket.get_all(bucket)
    assert all_events == %{
      "sound" => [8, 10],
      "humidness" => [5]
    }
  end
end
