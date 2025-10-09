defmodule ChronoPulse.Leave do
  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.Leave.LeaveRequestApproval
  alias ChronoPulse.Attendance  # context module

  def list_leave_requests do
    Repo.all(LeaveRequestApproval)
  end

  def get_leave_request!(id), do: Repo.get!(LeaveRequestApproval, id)

  def create_leave_request(attrs \\ %{}) do
    %LeaveRequestApproval{}
    |> LeaveRequestApproval.changeset(attrs)
    |> Repo.insert()
  end

  def update_leave_request(%LeaveRequestApproval{} = request, attrs) do
    Repo.transaction(fn ->
      request
      |> LeaveRequestApproval.changeset(attrs)
      |> Repo.update()
      |> case do
        {:ok, updated_request} ->
          # Update linked attendance if approved
          if updated_request.status == "approved" do
            attendance = Attendance.get_attendance!(updated_request.attendance_id)
            Attendance.update_attendance(attendance, %{status: "on_leave"})
          end

          {:ok, updated_request}

        error -> error
      end
    end)
  end

  def delete_leave_request(%LeaveRequestApproval{} = request) do
    Repo.delete(request)
  end
end
