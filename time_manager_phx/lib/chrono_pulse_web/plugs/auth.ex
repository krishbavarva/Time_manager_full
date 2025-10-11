defmodule ChronoPulseWeb.Plugs.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] ->
        if String.starts_with?(token, "dummy-jwt-token-") do
          # Extract user info from token or use a mapping system
          # For now, we'll use the token to determine which user is logged in
          user = get_user_from_token(token)
          assign(conn, :current_user, user)
        else
          # If token doesn't match expected format, set guest user
          assign(conn, :current_user, %{role: "guest", id: nil})
        end
      _ ->
        # No token provided, set guest user
        assign(conn, :current_user, %{role: "guest", id: nil})
    end
  end

  # Simple token to user mapping for testing
  # In production, this would be proper JWT validation
  defp get_user_from_token(token) do
    # Extract user identifier from token (this is a simple approach for testing)
    # In production, you'd decode the JWT token properly
    
    # For testing, we'll use a simple mapping based on token content
    case token do
      # Admin user
      "dummy-jwt-token-24755B262087A4EFF9658C5EB019DAFE00AFB47F2CD75BE0772BAE856239B01C" ->
        %{
          id: "94d9fa7d-5745-4317-bf6a-a6d94d40a2bc",
          username: "ADMIN",
          email: "admin@gmail.com",
          first_name: "admin",
          last_name: "-",
          role: "admin"
        }
      
      # Employee user - happy bavarva
      "dummy-jwt-token-happy-user" ->
        %{
          id: "f53addc6-3c6a-4751-bfa6-c3ad7f09c53c",
          username: "happy",
          email: "krishbavarva168@gmail.com",
          first_name: "happy",
          last_name: "bavarva",
          role: "employee"
        }
      
      # Manager user
      "dummy-jwt-token-manager-user" ->
        %{
          id: "b68d96c2-b885-4313-8175-65dd1d75f801",
          username: "MANAGER",
          email: "manager@gmail.com",
          first_name: "manager",
          last_name: "-",
          role: "manager"
        }
      
      # Default to admin for any other valid token (for backward compatibility)
      _ ->
        %{
          id: "94d9fa7d-5745-4317-bf6a-a6d94d40a2bc",
          username: "ADMIN",
          email: "admin@gmail.com",
          first_name: "admin",
          last_name: "-",
          role: "admin"
        }
    end
  end
end
