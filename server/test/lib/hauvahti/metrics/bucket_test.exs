defmodule Hauvahti.Metrics.BucketTest do
  use ExUnit.Case, async: true

  alias Hauvahti.Metrics.Bucket

  setup do
    {:ok, bucket} = Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "registering new event", %{bucket: bucket} do
    events = bucket
    |> Bucket.register({"volume", 10})
    |> Bucket.get("volume")

    assert events == [10]
  end

  test "registering existing event", %{bucket: bucket} do
    events = bucket
    |> Bucket.register({"volume", 10})
    |> Bucket.register({"volume", 20})
    |> Bucket.get("volume")

    assert events == [20, 10]
  end

  test "fetching all events", %{bucket: bucket} do
    events = bucket
    |> Bucket.register({"volume", 10})
    |> Bucket.register({"humidity", 20})
    |> Bucket.register({"volume", 20})
    |> Bucket.get_all

    assert events == %{
      "volume" => [20, 10],
      "humidity" => [20]
    }
  end

  test "fetching non-existing metrics type", %{bucket: bucket} do
    events = Bucket.get(bucket, "foobar")
    assert events == nil
  end
end
