defmodule Hauvahti.Metrics.BucketTest do
  use ExUnit.Case, async: true

  alias Hauvahti.Metrics.Bucket

  setup do
    {:ok, bucket} = Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "registering events for new metric type", %{bucket: bucket} do
    returned_events = bucket
    |> Bucket.register("sound=10")
    |> Bucket.get("sound")

    assert returned_events == [10]
  end

  test "registering events for existing metrics type", %{bucket: bucket} do
    bucket
    |> Bucket.register("sound=10")
    |> Bucket.register("sound=20")
    |> Bucket.register("sound=5")

    returned_events = Bucket.get(bucket, "sound")
    assert returned_events == [5,20,10]
  end

  test "registering multiple events at once", %{bucket: bucket} do
    events = ["sound=10", "volume=20", "sound=10"]
    Bucket.register(bucket, Enum.join(events, "\n"))

    assert Bucket.get(bucket, "sound") == [10, 10]
    assert Bucket.get(bucket, "volume") == [20]
  end

  test "fetching events for non-existing metrics type", %{bucket: bucket} do
    returned_events = Bucket.get(bucket, "foobar")
    assert returned_events == nil
  end

  test "fetching all events", %{bucket: bucket} do
    bucket
    |> Bucket.register("sound=10")
    |> Bucket.register("humidness=5")
    |> Bucket.register("sound=8")

    all_events = Bucket.get_all(bucket)
    assert all_events == %{
      "sound" => [8, 10],
      "humidness" => [5]
    }
  end
end
