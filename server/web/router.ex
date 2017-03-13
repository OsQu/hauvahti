defmodule Hauvahti.Router do
  use Hauvahti.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Hauvahti do
    pipe_through :api

    resources "/metrics", MetricsController, only: [:create]
  end
end
