defmodule ChronoPulse.Repo.Migrations.AddPayToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :pay, :float, default: 0.0
    end
  end
end
