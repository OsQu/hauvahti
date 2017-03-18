defmodule Hauvahti.MetricsController do
  use Hauvahti.Web, :controller

  alias Hauvahti.User

  plug :authenticate

  def create(conn, _params) do
    json conn, %{hello: "world"}
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
