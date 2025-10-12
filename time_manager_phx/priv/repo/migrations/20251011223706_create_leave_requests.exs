defmodule ChronoPulse.Repo.Migrations.CreateLeaveRequests do
  use Ecto.Migration

  def change do
    create table(:leave_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
      add :leave_type, :string, null: false # "sick", "vacation", "personal", "emergency", "holiday"
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :duration_type, :string, default: "full_day", null: false # "full_day", "half_day_morning", "half_day_afternoon"
      add :reason, :text, null: false
      add :status, :string, default: "pending", null: false # "pending", "approved", "rejected"
      add :approved_by_id, references(:users, type: :binary_id, on_delete: :nilify_all)
      add :admin_notes, :text
      add :total_days, :decimal, precision: 3, scale: 1, default: 1.0 # 1.0 for full day, 0.5 for half day

      timestamps(type: :utc_datetime)
    end

    create index(:leave_requests, [:user_id])
    create index(:leave_requests, [:status])
    create index(:leave_requests, [:start_date])
    create index(:leave_requests, [:approved_by_id])
    create index(:leave_requests, [:leave_type])
  end
end