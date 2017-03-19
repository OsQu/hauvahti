defmodule Hauvahti.Metrics.BucketTest do
  use ExUnit.Case, async: true

  alias Hauvahti.Metrics.Bucket

  setup do
    {:ok, bucket} = Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "registering events for new metric type", %{bucket: bucket} do
    returned_events = bucket
    |> Bucket.register(["sound=10"])
    |> Bucket.get("sound")

    assert returned_events == [10]
  end

  test "registering events for existing metrics type", %{bucket: bucket} do
    bucket
    |> Bucket.register(["sound=10", "sound=20", "sound=5"])

    returned_events = Bucket.get(bucket, "sound")
    assert returned_events == [5,20,10]
  end

  test "fetching events for non-existing metrics type", %{bucket: bucket} do
    returned_events = Bucket.get(bucket, "foobar")
    assert returned_events == nil
  end

  test "fetching all events", %{bucket: bucket} do
    bucket
    |> Bucket.register(["sound=10"])
    |> Bucket.register(["humidness=5"])
    |> Bucket.register(["sound=8"])

    all_events = Bucket.get_all(bucket)
    assert all_events == %{
      "sound" => [8, 10],
      "humidness" => [5]
    }
  end
end
