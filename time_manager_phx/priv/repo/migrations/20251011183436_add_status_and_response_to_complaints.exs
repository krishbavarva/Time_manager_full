defmodule ChronoPulse.Repo.Migrations.AddStatusAndResponseToComplaints do
  use Ecto.Migration

  def change do
    alter table(:user_complaints) do
      add :status, :string, default: "pending", null: false
      add :admin_response, :text
    end
  end
end
