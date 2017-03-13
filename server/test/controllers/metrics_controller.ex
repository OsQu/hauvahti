defmodule Hauvahti.MetricsController do
  use Hauvahti.Web, :controller

  def create(conn, _params) do
    json conn, %{hello: "world"}
  end
end
