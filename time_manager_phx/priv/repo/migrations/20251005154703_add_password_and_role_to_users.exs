defmodule ChronoPulse.Repo.Migrations.AddPasswordAndRoleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hashed_password, :string, null: true
      add :role, :string, null: false, default: "employee"
    end

    # Backfill existing users with a default hashed password
    execute "UPDATE users SET hashed_password = 'temporary_password_123' WHERE hashed_password IS NULL"
    
    # Now we can alter the column to be non-null
    alter table(:users) do
      modify :hashed_password, :string, null: false
    end

    # Only create the index if it doesn't already exist
    create_if_not_exists index(:users, [:email], unique: true, name: :users_email_index)
    create_if_not_exists index(:users, [:username], unique: true, name: :users_username_index)
  end
end
