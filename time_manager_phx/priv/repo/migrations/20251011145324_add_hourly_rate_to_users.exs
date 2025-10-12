defmodule ChronoPulse.Repo.Migrations.AddHourlyRateToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :hourly_rate, :float, default: 15.0  # Default 15 euro per hour
    end
  end
end
