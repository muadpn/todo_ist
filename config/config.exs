# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :todo_ist,
  ecto_repos: [TodoIst.Repo],
  generators: [timestamp_type: :utc_datetime]

config :todo_ist, TodoIst.Guardian,
  issuer: "todo_ist",
  secret_key: "j3VV9xO//OVdNdyw99CJSC4sjqMeA5iiDhZ6KeEnhvbBz/vsmFoCe7/GPcXZry6n"

# Configures the endpoint
config :todo_ist, TodoIstWeb.Endpoint,
  url: [host: "0.0.0.0"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TodoIstWeb.ErrorHTML, json: TodoIstWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TodoIst.PubSub,
  live_view: [signing_salt: "iIzm1uP+"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :todo_ist, TodoIst.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
