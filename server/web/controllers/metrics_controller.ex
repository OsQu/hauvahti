defmodule Hauvahti.MetricsController do
  use Hauvahti.Web, :controller

  alias Hauvahti.User
  alias Hauvahti.Metrics.Store

  plug :authenticate

  def index(conn, _params) do
    case Store.metrics(Store, conn.assigns[:user].id) do
      metrics = %{} -> json(conn, metrics)
      nil -> json(conn, [])
    end
  end

  def create(conn, params) do
    Store.save(Store, conn.assigns[:user].id, params["events"])

    conn
    |> put_status(202)
    |> json(%{"message": "Accepted"})
  end

  defp authenticate(%{params: %{"token" => token}} = conn, _params) do
    case User |> Ecto.Query.where(token: ^token) |> Repo.one do
      user = %User{} -> conn |> assign(:user, user)
                   _ -> conn |> render_authentication_error |> halt
    end
  end

  defp render_authentication_error(conn) do
    conn
    |> put_status(403)
    |> json(%{error: "Access denied"})
  end
end
