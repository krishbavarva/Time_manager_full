import Config

config :chrono_pulse, ChronoPulse.Repo,
  username: System.get_env("PGUSER") || "postgres",
  password: System.get_env("PGPASSWORD") || "postgres",
  hostname: System.get_env("PGHOST") || "chrono_postgres",
  database: System.get_env("PGDATABASE") || "chrono_pulse_prod",
  port: String.to_integer(System.get_env("PGPORT") || "5432"),
  pool_size: 10,
  ssl: false

config :chrono_pulse, ChronoPulseWeb.Endpoint,
  http: [
    ip: {0, 0, 0, 0},  # ✅ Allow access from any IP (needed for mobile app)
    port: String.to_integer(System.get_env("PORT") || "4000")
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || "something-very-long-and-random",
  server: true,
  check_origin: false,   # ✅ Disable strict origin checking in production (only safe if internal/local use)
  code_reloader: false

# ✅ Add CORS for mobile app access
config :cors_plug,
  origin: ["*"],   # In real production: replace "*" with your app’s domain or IP
  max_age: 86400,
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"]
