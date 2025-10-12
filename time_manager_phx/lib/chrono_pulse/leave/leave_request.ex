defmodule ChronoPulse.Leave.LeaveRequest do
  use Ecto.Schema
  import Ecto.Changeset

  alias ChronoPulse.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  
  schema "leave_requests" do
    belongs_to :user, User
    belongs_to :approved_by, User, foreign_key: :approved_by_id
    
    field :leave_type, :string
    field :start_date, :date
    field :end_date, :date
    field :duration_type, :string
    field :reason, :string
    field :status, :string
    field :admin_notes, :string
    field :total_days, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(leave_request, attrs) do
    leave_request
    |> cast(attrs, [:user_id, :leave_type, :start_date, :end_date, :duration_type, :reason, :status, :approved_by_id, :admin_notes, :total_days])
    |> validate_required([:user_id, :leave_type, :start_date, :end_date, :reason])
    |> validate_inclusion(:leave_type, ["sick", "vacation", "personal", "emergency", "holiday"])
    |> validate_inclusion(:duration_type, ["full_day", "half_day_morning", "half_day_afternoon"])
    |> validate_inclusion(:status, ["pending", "approved", "rejected"])
    |> validate_date_range()
    |> calculate_total_days()
    |> validate_length(:reason, min: 10, max: 500)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:approved_by_id)
  end

  defp validate_date_range(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    case {start_date, end_date} do
      {nil, _} -> changeset
      {_, nil} -> changeset
      {start_date, end_date} ->
        if Date.compare(start_date, end_date) == :gt do
          add_error(changeset, :end_date, "End date must be after or equal to start date")
        else
          changeset
        end
    end
  end

  defp calculate_total_days(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)
    duration_type = get_field(changeset, :duration_type)

    case {start_date, end_date, duration_type} do
      {nil, _, _} -> changeset
      {_, nil, _} -> changeset
      {start_date, end_date, duration_type} ->
        days_diff = Date.diff(end_date, start_date) + 1
        
        total_days = case duration_type do
          "full_day" -> Decimal.new(days_diff)
          "half_day_morning" -> Decimal.new(days_diff) |> Decimal.div(2)
          "half_day_afternoon" -> Decimal.new(days_diff) |> Decimal.div(2)
          _ -> Decimal.new(days_diff)
        end
        
        put_change(changeset, :total_days, total_days)
    end
  end
end
