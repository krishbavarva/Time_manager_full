defmodule ChronoPulseWeb.Plugs.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        # For now, accept any token and set a default admin user for testing
        # In production, you'd want proper JWT validation
        if String.starts_with?(token, "dummy-jwt-token-") do
          assign(conn, :current_user, %{
            id: "test-admin-id",
            username: "test_admin",
            email: "admin@example.com",
            first_name: "Test",
            last_name: "Admin",
            role: "admin"
          })
        else
          # If token doesn't match expected format, set guest user
          assign(conn, :current_user, %{role: "guest", id: nil})
        end
      _ ->
        # No token provided, set guest user
        assign(conn, :current_user, %{role: "guest", id: nil})
    end
  end
end
