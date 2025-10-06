defmodule ChronoPulseWeb.UserController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.Accounts
  alias ChronoPulse.Accounts.User
  alias ChronoPulse.TimeTracking

  action_fallback ChronoPulseWeb.FallbackController

  def index(conn, params) do
    require Logger
    Logger.info("UserController.index called with params: #{inspect(params)}")
    
    try do
      username = Map.get(params, "username")
      email = Map.get(params, "email")
      
      Logger.info("Searching users with username: #{inspect(username)}, email: #{inspect(email)}")
      users = Accounts.search_users(username, email)
      Logger.info("Found #{length(users)} users")
      
      # Log the first user's data if available
      if length(users) > 0 do
        Logger.info("First user data: #{inspect(List.first(users))}")
      end
      
      # Explicitly specify the JSON format
      json(conn, %{data: Enum.map(users, &user_json/1)})
    rescue
      error ->
        Logger.error("Error in UserController.index: #{inspect(error)}")
        Logger.error("Stacktrace: #{inspect(__STACKTRACE__)}")
        send_resp(conn, 500, "Internal server error")
    end
  end

  # Helper function to convert User struct to JSON
  defp user_json(%ChronoPulse.Accounts.User{} = user) do
    %{
      id: user.id,
      username: user.username,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      role: user.role || "employee"
    }
  end

  def create(conn, %{"user" => user_params}) do
    # Convert role to string and ensure it's a valid role
    role = 
      case user_params["role"] do
        nil -> "employee"
        role when role in ["admin", "manager", "employee"] -> role
        _ -> "employee"
      end
    
    # Prepare user params with hashed password
    user_params = 
      user_params
      |> Map.put("role", role)
      |> Map.put("hashed_password", Bcrypt.hash_pwd_salt(user_params["password"] || ""))
    
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/users/#{user.id}")
      |> render(:show, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, :show, user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)
    current_user = conn.assigns[:current_user] || %{role: "guest"}
    
    # Only allow admins to change roles
    user_params = 
      if current_user.role == "admin" do
        user_params
      else
        Map.delete(user_params, "role")
      end
    
    # Handle password update if provided
    user_params =
      case user_params["password"] do
        nil ->
          Map.delete(user_params, "password")
        "" ->
          Map.delete(user_params, "password")
        password ->
          user_params
          |> Map.put("hashed_password", Bcrypt.hash_pwd_salt(password))
          |> Map.delete("password")
      end

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, :show, user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    # Delete dependent records first to avoid FK constraint errors
    TimeTracking.delete_all_for_user(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
