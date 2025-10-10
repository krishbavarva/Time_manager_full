defmodule ChronoPulse.Repo.Migrations.AddTimeCalculationFieldsToWorkingtimes do
  use Ecto.Migration

  def change do
    alter table(:workingtimes) do
      add :scheduled_hours, :float
      add :actual_hours, :float
      add :break_hours, :float
      add :overtime_hours, :float
      add :status, :string, default: "pending"
      add :approved_by, :binary_id
    end

    create index(:workingtimes, [:status])
    create index(:workingtimes, [:approved_by])
  end
end
