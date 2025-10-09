defmodule ChronoPulse.Repo.Migrations.CreateLeaveRequestApprovals do
  use Ecto.Migration

  def change do
    create table(:leave_request_approvals, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :attendance_id, references(:attendance, type: :binary_id, on_delete: :delete_all), null: false
      add :status, :string, default: "pending", null: false # pending, approved, rejected

      timestamps(type: :utc_datetime)
    end

    create index(:leave_request_approvals, [:user_id])
    create index(:leave_request_approvals, [:attendance_id])
  end
end
