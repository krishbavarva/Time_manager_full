defmodule ChronoPulse.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  
  # Role types
  @roles ~w(admin manager employee)
  
  schema "users" do
    field :username, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true
    field :role, :string, default: "employee"

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.
  It's important to validate the length of both email and password.
  Otherwise, databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username, :email, :password, :first_name, :last_name, :role])
    |> validate_required([:username, :email, :password, :first_name, :last_name, :role])
    |> validate_email()
    |> validate_username()
    |> validate_password(opts)
    |> validate_inclusion(:role, @roles, message: "must be one of: #{Enum.join(@roles, ", ")}")
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email], message: "can't be blank")
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160, message: "should be at most 160 character(s)")
    |> unsafe_validate_unique(:email, ChronoPulse.Repo, message: "has already been taken")
    |> unique_constraint(:email, message: "has already been taken")
  end

  defp validate_username(changeset) do
    changeset
    |> validate_required([:username], message: "can't be blank")
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/, message: "can only contain letters, numbers, and underscores")
    |> validate_length(:username, min: 3, max: 50, message: "should be between 3 and 50 characters")
    |> unsafe_validate_unique(:username, ChronoPulse.Repo, message: "has already been taken")
    |> unique_constraint(:username, message: "has already been taken")
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 72)
    # Add more password validations as needed
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for updating user information.
  It requires the password to match the current value.
  """
  def update_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :username, :first_name, :last_name, :role])
    |> validate_email()
    |> validate_username()
    |> validate_inclusion(:role, @roles, message: "must be one of: #{Enum.join(@roles, ", ")}")
    |> maybe_validate_password(opts)
  end

  defp maybe_validate_password(changeset, opts) do
    if opts[:password_required] do
      changeset
      |> validate_required([:current_password])
      |> validate_current_password()
    else
      changeset
    end
  end

  defp validate_current_password(changeset) do
    current_password = get_change(changeset, :current_password)
    user = changeset.data
    
    if current_password && Bcrypt.verify_pass(current_password, user.hashed_password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  @doc """
  Verifies the password.
  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%ChronoPulse.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end
end
