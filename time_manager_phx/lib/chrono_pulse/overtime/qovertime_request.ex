defmodule ChronoPulse.Overtime.OvertimeRequest do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChronoPulse.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "overtime_requests" do
    field :hours, :float
    field :reason, :string
    field :status, :string, default: "pending"

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(request, attrs) do
    request
    |> cast(attrs, [:user_id, :hours, :reason, :status])
    |> validate_required([:user_id, :hours])
    |> validate_inclusion(:status, ["pending", "approved", "rejected"])
  end
end
