defmodule ChronoPulseWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :chrono_pulse

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_time_manager_phx_key",
    signing_salt: "ofsD/gik",
    same_site: "Lax"
  ]

  # ✅ Add CORSPlug here (outside of the code_reloading block)
  plug CORSPlug, origin: "*"

  # Serve static files from "priv/static"
  plug Plug.Static,
    at: "/",
    from: :chrono_pulse,
    gzip: not code_reloading?,
    only: ChronoPulseWeb.static_paths()

  # Enable code reloading in development
  if code_reloading? do
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :chrono_pulse
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options

  plug ChronoPulseWeb.Router
end
