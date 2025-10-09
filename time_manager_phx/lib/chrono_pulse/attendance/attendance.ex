defmodule ChronoPulse.Attendance.Attendance do
  use Ecto.Schema
  import Ecto.Changeset

  alias ChronoPulse.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "attendance" do
    belongs_to :user, User
    field :date, :date
    field :status, :string  # "present", "absent", or "on_leave"

    timestamps(type: :utc_datetime)
  end

  def changeset(attendance, attrs) do
    attendance
    |> cast(attrs, [:user_id, :date, :status])
    |> validate_required([:user_id, :date, :status])
    |> validate_inclusion(:status, ["present", "absent", "on_leave"])
  end
end
