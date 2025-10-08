defmodule ChronoPulse.Repo.Migrations.CreateOvertimeRequests do
  use Ecto.Migration

  def change do
    create table(:overtime_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :hours, :float, null: false
      add :reason, :string
      add :status, :string, default: "pending"  # pending | approved | rejected

      timestamps(type: :utc_datetime)
    end

    create index(:overtime_requests, [:user_id])
  end
end
