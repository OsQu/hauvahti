# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :hauvahti,
  ecto_repos: [Hauvahti.Repo]

# Configures the endpoint
config :hauvahti, Hauvahti.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "miS3+qvL2JzFmTXx5/rrwWsv0YEXXwoH5He3VezrYgfgQmDfGn5V6fwhn16P1uki",
  render_errors: [view: Hauvahti.ErrorView, accepts: ~w(json)],
  pubsub: [name: Hauvahti.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
