defmodule Hauvahti.MetricsControllerTest do
  use Hauvahti.ConnCase

  alias Hauvahti.{Repo, User}

  setup do
    token = "user_token"
    Repo.insert(%User{name: "Test User", token: token})
    {:ok, token: token}
  end


  describe "authentication for POST /metrics" do
    test "allows requests with correct token", %{token: token} do
      response = build_conn()
      |> post(metrics_path(build_conn(), :create, token))
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

  describe "sending metrics to submodule" do
  end
end
