defmodule ChronoPulse.TimeTracking.Clock do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "clocks" do
    field :time, :utc_datetime
    field :status, :boolean
    field :user_id, :binary_id
    field :latitude, :float
    field :longitude, :float

    timestamps(type: :utc_datetime)
  end

  def changeset(clock, attrs) do
    clock
    |> cast(attrs, [:time, :status, :user_id, :latitude, :longitude])
    |> validate_required([:time, :status, :user_id])
  end
end



