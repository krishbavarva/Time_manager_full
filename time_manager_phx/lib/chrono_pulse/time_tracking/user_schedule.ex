defmodule ChronoPulse.TimeTracking.UserSchedule do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "user_schedules" do
    field :user_id, :binary_id
    field :day_of_week, :string  # "monday", "tuesday", etc.
    field :scheduled_start_time, :time
    field :scheduled_end_time, :time
    field :scheduled_hours, :float
    field :is_active, :boolean, default: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_schedule, attrs) do
    user_schedule
    |> cast(attrs, [:user_id, :day_of_week, :scheduled_start_time, :scheduled_end_time, :scheduled_hours, :is_active])
    |> validate_required([:user_id, :day_of_week, :scheduled_start_time, :scheduled_end_time])
    |> validate_inclusion(:day_of_week, ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"])
    |> validate_number(:scheduled_hours, greater_than: 0, less_than: 24)
    |> validate_number(:scheduled_hours, greater_than: 0, less_than: 24)
  end
end
