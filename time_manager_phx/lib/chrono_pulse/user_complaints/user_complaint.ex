defmodule ChronoPulse.UserComplaints.UserComplaint do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :user_id, :complaint, :status, :admin_response, :inserted_at, :updated_at]}
  schema "user_complaints" do
    field :complaint, :string
    field :status, :string, default: "pending"
    field :admin_response, :string
    field :user_id, :binary_id

    timestamps()
  end

  def changeset(user_complaint, attrs) do
    user_complaint
    |> cast(attrs, [:user_id, :complaint, :status, :admin_response])
    |> validate_required([:user_id, :complaint])
    |> validate_inclusion(:status, ["pending", "resolved", "closed"])
  end
end
