defmodule ChronoPulse.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bcrypt  # or Argon2 depending on your lib

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :username, :string
    field :email, :string
    field :first_name, :string
    field :last_name, :string

    # auth fields
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :role, :string, default: "employee"

    # new field for hourly pay
    field :pay, :float, default: 0.0

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
  |> cast(attrs, [:username, :email, :first_name, :last_name, :password, :role, :pay])
  |> validate_required([:username, :email, :password, :role, :pay])
  |> validate_inclusion(:role, ["employee", "manager", "admin"])
  |> unique_constraint(:email)
  |> unique_constraint(:username)
  |> validate_length(:password, min: 6)
  |> validate_number(:pay, greater_than_or_equal_to: 0)  # ensure non-negative pay
  |> put_password_hash()
end

  defp put_password_hash(changeset) do
    case get_change(changeset, :password) do
      nil -> changeset
      password ->
        change(changeset, hashed_password: Bcrypt.hash_pwd_salt(password))
  end
end



end
