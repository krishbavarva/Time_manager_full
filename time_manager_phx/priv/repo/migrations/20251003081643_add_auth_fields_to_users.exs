defmodule ChronoPulse.Repo.Migrations.AddAuthFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hashed_password, :string
      add :role, :string
    end
  end
end
