defmodule ChronoPulse.Repo.Migrations.AddFlexibleTimeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :flexible_time_enabled, :boolean, default: false, null: false
    end
    
    # Create index for faster queries
    create index(:users, [:flexible_time_enabled])
  end
end
