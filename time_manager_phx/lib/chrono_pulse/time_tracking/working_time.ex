defmodule ChronoPulse.TimeTracking.WorkingTime do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "workingtimes" do
    field :start, :utc_datetime
    field :end, :utc_datetime
    field :user_id, :binary_id
    field :scheduled_hours, :float
    field :actual_hours, :float
    field :break_hours, :float
    field :overtime_hours, :float
    field :status, :string, default: "pending"  # "pending", "approved", "rejected"
    field :approved_by, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(working_time, attrs) do
    working_time
    |> cast(attrs, [:start, :end, :user_id, :scheduled_hours, :actual_hours, :break_hours, :overtime_hours, :status, :approved_by])
    |> validate_required([:start, :end, :user_id])
    |> validate_inclusion(:status, ["pending", "approved", "rejected"])
  end
end
