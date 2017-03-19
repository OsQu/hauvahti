defmodule Hauvahti.MetricsControllerTest do
  use Hauvahti.ConnCase

  alias Hauvahti.{Repo, User}
  alias Hauvahti.Metrics.Store

  setup do
    token = "user_token"
    {:ok , user} = Repo.insert(%User{name: "Test User", token: token})
    {:ok, token: token, user: user}
  end


  describe "authentication for POST /metrics" do
    test "allows requests with correct token", %{token: token} do
      response = build_conn()
      |> post(metrics_path(build_conn(), :create, token), events: "sound=10")
      |> json_response(202)

      assert response == %{"message" => "Accepted"}
    end

    test "denies requests with invalid token" do
      response = build_conn()
      |> post(metrics_path(build_conn(), :create, "invalid_token"))
      |> json_response(403)

      assert response == %{"error" => "Access denied"}
    end
  end

  describe "dispatching metrics" do
    test "sends metrics to metrics dispatcher", %{token: token, user: user} do
      events = Enum.join([
        "volume=10",
        "volume=20",
        "humidity=10",
        "volume=10",
        "humidity=30"
      ], ",")

      build_conn()
      |> post(metrics_path(build_conn(), :create, token), events: events)
      |> json_response(202)

      metrics = Store.metrics(Store, user.id)
      assert metrics == %{"volume" => [10,20,10], "humidity" => [30, 10]}
    end
  end

  describe "fetching metrics" do
    test "returning events for user", %{token: token} do
      events = Enum.join([
        "volume=10",
        "volume=20",
        "humidity=10",
        "volume=10",
        "humidity=30"
      ], ",")

      build_conn()
      |> post(metrics_path(build_conn(), :create, token), events: events)
      |> json_response(202)

      response = build_conn()
      |> get(metrics_path(build_conn(), :index, token))
      |> json_response(200)

      assert response == %{"volume" => [10,20,10], "humidity" => [30,10]}
    end

    test "returning [] for empty user", %{token: token} do
      response = build_conn()
      |> get(metrics_path(build_conn(), :index, token))
      |> json_response(200)

      assert response == []
    end
  end
end
