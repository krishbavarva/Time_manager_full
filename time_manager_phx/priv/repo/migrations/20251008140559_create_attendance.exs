defmodule ChronoPulse.Repo.Migrations.CreateAttendance do
  use Ecto.Migration

  def change do
    create table(:attendance, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :date, :date
      add :status, :string

      timestamps(type: :utc_datetime)
    end

    create index(:attendance, [:user_id])
  end
end
