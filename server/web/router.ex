defmodule Hauvahti.Router do
  use Hauvahti.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Hauvahti do
    pipe_through :api

    post "/metrics/:token", MetricsController, :create
    get "/metrics/:token", MetricsController, :index
  end
end
