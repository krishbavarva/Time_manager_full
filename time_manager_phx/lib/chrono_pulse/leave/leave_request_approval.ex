defmodule ChronoPulse.Leave.LeaveRequestApproval do
  use Ecto.Schema
  import Ecto.Changeset

  alias ChronoPulse.Accounts.User
  alias ChronoPulse.Attendance.Attendance

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "leave_request_approvals" do
    belongs_to :user, User
    belongs_to :attendance, Attendance
    field :status, :string, default: "pending"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(leave_request, attrs) do
    leave_request
    |> cast(attrs, [:user_id, :attendance_id, :status])
    |> validate_required([:user_id, :attendance_id, :status])
    |> validate_inclusion(:status, ["pending", "approved", "rejected"])
  end
end
