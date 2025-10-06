defmodule ChronoPulse.Repo.Migrations.FixUserPasswordAndRole do
  use Ecto.Migration

  def change do
    # First, drop the not null constraint if it exists
    alter table(:users) do
      modify :hashed_password, :string, null: true
    end

    # Backfill any null hashed_passwords with a temporary password
    execute "UPDATE users SET hashed_password = 'temporary_password_123' WHERE hashed_password IS NULL"

    # Now we can safely add the not null constraint
    alter table(:users) do
      modify :hashed_password, :string, null: false
    end

    # Ensure the role column exists and has a default value
    alter table(:users) do
      modify :role, :string, null: false, default: "employee"
    end

    # Create indexes if they don't exist
    create_if_not_exists index(:users, [:email], unique: true, name: :users_email_index)
    create_if_not_exists index(:users, [:username], unique: true, name: :users_username_index)
  end
end
