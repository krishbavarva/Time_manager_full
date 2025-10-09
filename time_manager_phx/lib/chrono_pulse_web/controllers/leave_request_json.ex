defmodule ChronoPulseWeb.LeaveRequestJSON do
  alias ChronoPulse.Leave.LeaveRequestApproval

  def index(%{leave_requests: records}) do
    %{data: Enum.map(records, &data/1)}
  end

  def show(%{leave_request: record}) do
    %{data: data(record)}
  end

  defp data(%LeaveRequestApproval{} = record) do
    %{
      id: record.id,
      user_id: record.user_id,
      attendance_id: record.attendance_id,
      status: record.status,
      inserted_at: record.inserted_at,
      updated_at: record.updated_at
    }
  end
end
