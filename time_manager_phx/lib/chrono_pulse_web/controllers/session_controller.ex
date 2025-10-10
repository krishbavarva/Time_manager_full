defmodule ChronoPulseWeb.SessionController do
  use ChronoPulseWeb, :controller
  alias ChronoPulse.Accounts

  def create(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        token = generate_token(%{
          user_id: user.id,
          email: user.email,
          role: user.role || "user"
        })
        
        conn
        |> put_status(:ok)
        |> render(:token, token: token)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid email or password"})
    end
  end

  defp generate_token(claims) do
    "dummy-jwt-token-#{Base.encode16(:crypto.hash(:sha256, Jason.encode!(claims)))}"
  end
end
