# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :bayaq,
  ecto_repos: [Bayaq.Repo]

# Configures the endpoint
config :bayaq, BayaqWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "S5Czv08yLWHbiM5eoRiUHQLbxMEOAqkC2QHn+wjQ9pWVJVXQhpNTGI1GaDBvypyJ",
  render_errors: [view: BayaqWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bayaq.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason


config :bayaq, Bayaq.Accounts.Guardian,
  issuer: "bayaq", # Name of your app/company/product
  secret_key: "sf/dnMKYVw9YfRs5mFDyPkT7Rm/bnatbEsf8QmJWLtf24PGhTCTF7dqU/9HogDTx"


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :money,
  default_currency: :MYR,           # this allows you to do Money.new(100)
  separator: ",",                   # change the default thousands separator for Money.to_string
  delimiter: ".",                   # change the default decimal delimeter for Money.to_string
  symbol: false,                    # don’t display the currency symbol in Money.to_string
  symbol_on_right: false,           # position the symbol
  symbol_space: false,               # add a space between symbol and number
  fractional_unit: true,             # display units after the delimeter
  strip_insignificant_zeros: false
