defmodule ChronoPulse.Repo.Migrations.MakeManagerIdNullable do
  use Ecto.Migration

  def change do
    drop constraint(:teams, :teams_manager_id_fkey)
    alter table(:teams) do
      modify :manager_id, references(:users, type: :binary_id, on_delete: :nothing), null: true
    end
  end
end
