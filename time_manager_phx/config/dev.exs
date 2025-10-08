import Config

# Configure your database (PostgreSQL for development)
config :chrono_pulse, ChronoPulse.Repo,
  username: System.get_env("PGUSER") || "postgres",
  password: System.get_env("PGPASSWORD") || "postgres",
  hostname: System.get_env("PGHOST") || "localhost",
  port: String.to_integer(System.get_env("PGPORT") || "5432"),
  database: System.get_env("PGDATABASE") || "chrono_pulse_dev",
  pool_size: 10,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

# Phoenix endpoint configuration for development
config :chrono_pulse, ChronoPulseWeb.Endpoint,
  # ✅ Allow access from all devices on the same network
  http: [ip: {0, 0, 0, 0}, port: String.to_integer(System.get_env("PORT") || "4000")],

  # ✅ Disable CORS origin check during dev (needed for mobile app)
  check_origin: false,

  # ✅ Enable dev-time reloading and debug
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "DXizzy5h7K/dtoi8VrN5Fd4rko5sdhR+kDx+r+bM9G/l4w1yDNZLS2vMUVU03Xgy",
  watchers: []

# ✅ Add CORS (Cross-Origin Resource Sharing) support for your Cordova/Vue app
# This allows requests from your phone (e.g., 172.20.10.x)
config :cors_plug,
  origin: ["*"],    # Allow all origins during development
  max_age: 86400,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]

# Enable dev routes for dashboard and mailbox
config :chrono_pulse, dev_routes: true

# Do not include metadata nor timestamps in development logs
config :logger, :default_formatter, format: "[$level] $message\n"

# Set a higher stacktrace during development
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false
