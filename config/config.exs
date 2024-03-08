# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :blog_platform,
  ecto_repos: [BlogPlatform.Repo]

config :blog_platform, BlogPlatformWeb.Auth.GuardianCore,
  issuer: "blog_platform",
  # for each env use a different key, you can generate it by apply mix guardian.gen.secret
  secret_key: "HlY/VMrxDcAiuD5sXLc8ruoZysVBgeQVNYiioi+9MTg5Pnc/Lu20cVdd48me7Bm7"

  config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4,
                                 cleanup_interval_ms: 60_000 * 10]}


# Configures the endpoint
config :blog_platform, BlogPlatformWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: BlogPlatformWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: BlogPlatform.PubSub,
  live_view: [signing_salt: "sQaJkxxd"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :blog_platform, BlogPlatform.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :guardian, Guardian.DB,
  repo: BlogPlatform.Repo,
  schema_name: "guardian_tokens",
  sweep_interval: 60

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
