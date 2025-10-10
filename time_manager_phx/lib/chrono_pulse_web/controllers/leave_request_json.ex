defmodule ChronoPulseWeb.LeaveRequestJSON do
  @doc """
  Renders a list of leave requests.
  """
  def index(%{leave_requests: leave_requests}) do
    %{data: for(leave_request <- leave_requests, do: data(leave_request))}
  end

  @doc """
  Renders a single leave request.
  """
  def show(%{leave_request: leave_request}) do
    %{data: data(leave_request)}
  end

  defp data(%ChronoPulse.Leave.LeaveRequestApproval{} = leave_request) do
    %{
      id: leave_request.id,
      user_id: leave_request.user_id,
      attendance_id: leave_request.attendance_id,
      status: leave_request.status,
      inserted_at: leave_request.inserted_at,
      updated_at: leave_request.updated_at
    }
  end
end
