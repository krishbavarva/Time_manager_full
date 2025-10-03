defmodule ChronoPulse.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :manager_id, references(:users, type: :binary_id, on_delete: :nothing), null: false
      add :description, :text

      timestamps(type: :utc_datetime)
    end

    # Join table for employees
    create table(:teams_employees, primary_key: false) do
      add :team_id, references(:teams, type: :binary_id, on_delete: :delete_all), null: false
      add :employee_id, references(:users, type: :binary_id, on_delete: :delete_all), null: false
    end

    create unique_index(:teams_employees, [:team_id, :employee_id])
  end
end
