defmodule ChronoPulseWeb.LeaveRequestJSON do
  alias ChronoPulse.Leave.LeaveRequest

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

  defp data(%LeaveRequest{} = leave_request) do
    %{
      id: leave_request.id,
      user_id: leave_request.user_id,
      leave_type: leave_request.leave_type,
      start_date: leave_request.start_date,
      end_date: leave_request.end_date,
      duration_type: leave_request.duration_type,
      reason: leave_request.reason,
      status: leave_request.status,
      approved_by_id: leave_request.approved_by_id,
      admin_notes: leave_request.admin_notes,
      total_days: leave_request.total_days,
      inserted_at: leave_request.inserted_at,
      updated_at: leave_request.updated_at,
      user: user_data(leave_request.user),
      approved_by: approved_by_data(leave_request.approved_by)
    }
  end

  defp user_data(nil), do: nil
  defp user_data(user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      role: user.role
    }
  end

  defp approved_by_data(nil), do: nil
  defp approved_by_data(user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email
    }
  end
end