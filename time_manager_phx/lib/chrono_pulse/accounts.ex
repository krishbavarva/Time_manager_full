defmodule ChronoPulse.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias ChronoPulse.Repo

  alias ChronoPulse.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  @doc """
  Authenticates a user with the given email and password.
  Returns `{:ok, user}` if the credentials are valid, otherwise returns `{:error, reason}`.
  """
  def authenticate_user(email, password) when is_binary(email) and is_binary(password) do
    query = from u in User, where: u.email == ^email
    
    case Repo.one(query) do
      nil ->
        # Simulate password check to prevent timing attacks
        Bcrypt.no_user_verify()
        {:error, :not_found}
        
      user ->
        if Bcrypt.verify_pass(password, user.hashed_password) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

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
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      {:error, %Ecto.NoResultsError{}}

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user with the given attributes.

  ## Examples

      iex> create_user(%{email: "test@example.com", password: "password123", first_name: "John", last_name: "Doe"})
      {:ok, %User{}}

      iex> create_user(%{email: nil})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{first_name: "New Name"})
      {:ok, %User{}}

      iex> update_user(user, %{email: "not-an-email"})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs, opts \\ []) do
    user
    |> User.update_changeset(attrs, opts)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.update_changeset(user, attrs)
  end
end
