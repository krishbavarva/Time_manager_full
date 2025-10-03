defmodule ChronoPulse.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.Accounts.User

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Search users by optional username and/or email (case-insensitive, partial match).

  If both params are nil or empty, returns all users.
  """
  def search_users(username, email) do
    base = from u in User

    base =
      if is_binary(username) and String.trim(username) != "" do
        like = "%" <> String.replace(username, "%", "\\%") <> "%"
        from u in base, where: ilike(u.username, ^like)
      else
        base
      end

    base =
      if is_binary(email) and String.trim(email) != "" do
        like = "%" <> String.replace(email, "%", "\\%") <> "%"
        from u in base, where: ilike(u.email, ^like)
      else
        base
      end

    Repo.all(base)
  end

  @doc """
  Gets a single user by ID.
  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.
  Ensures password is hashed and type is validated.
  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  Will also re-hash password if provided in attrs.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Authenticate a user by email/username and password.
  Returns `{:ok, user}` if valid, otherwise `{:error, :unauthorized}`.
  """
  def authenticate_user(identifier, password) when is_binary(identifier) and is_binary(password) do
    user =
      Repo.get_by(User, email: identifier) ||
      Repo.get_by(User, username: identifier)

    cond do
      user && Bcrypt.verify_pass(password, user.hashed_password) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Bcrypt.no_user_verify()
        {:error, :unauthorized}
    end
  end
end
