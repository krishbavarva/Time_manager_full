defmodule ChronoPulse.Repo.Migrations.AddLatLngToClocks do
  use Ecto.Migration

  def change do
    alter table(:clocks) do
      add :latitude, :float
      add :longitude, :float
    end
  end
end
