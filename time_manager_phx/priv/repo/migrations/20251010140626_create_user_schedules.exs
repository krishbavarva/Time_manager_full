defmodule ChronoPulse.Repo.Migrations.CreateUserSchedules do
  use Ecto.Migration

  def change do
    create table(:user_schedules, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, :binary_id, null: false
      add :day_of_week, :string, null: false
      add :scheduled_start_time, :time, null: false
      add :scheduled_end_time, :time, null: false
      add :scheduled_hours, :float, null: false
      add :is_active, :boolean, default: true, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_schedules, [:user_id])
    create index(:user_schedules, [:day_of_week])
    create unique_index(:user_schedules, [:user_id, :day_of_week])
  end
end
