defmodule ChronoPulse.Leave do
  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.Leave.LeaveRequest

  # LeaveRequest functions
  def list_leave_requests do
    Repo.all(from lr in LeaveRequest, 
      preload: [:user, :approved_by],
      order_by: [desc: :inserted_at])
  end

  def list_leave_requests_by_user(user_id) do
    Repo.all(from lr in LeaveRequest, 
      where: lr.user_id == ^user_id,
      preload: [:user, :approved_by],
      order_by: [desc: :inserted_at])
  end

  def get_leave_request!(id) do
    Repo.get!(LeaveRequest, id)
    |> Repo.preload([:user, :approved_by])
  end

  def create_leave_request(attrs \\ %{}) do
    %LeaveRequest{}
    |> LeaveRequest.changeset(attrs)
    |> Repo.insert()
  end

  def update_leave_request(%LeaveRequest{} = request, attrs) do
    request
    |> LeaveRequest.changeset(attrs)
    |> Repo.update()
  end

  def approve_leave_request(%LeaveRequest{} = request, admin_user_id, admin_notes \\ nil) do
    request
    |> LeaveRequest.changeset(%{
      status: "approved",
      approved_by_id: admin_user_id,
      admin_notes: admin_notes
    })
    |> Repo.update()
  end

  def reject_leave_request(%LeaveRequest{} = request, admin_user_id, admin_notes \\ nil) do
    request
    |> LeaveRequest.changeset(%{
      status: "rejected",
      approved_by_id: admin_user_id,
      admin_notes: admin_notes
    })
    |> Repo.update()
  end

  def delete_leave_request(%LeaveRequest{} = request) do
    Repo.delete(request)
  end
end
