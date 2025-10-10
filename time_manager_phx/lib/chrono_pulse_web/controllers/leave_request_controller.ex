defmodule ChronoPulseWeb.LeaveRequestController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.Leave
  alias ChronoPulse.Leave.LeaveRequestApproval
  alias ChronoPulseWeb.LeaveRequestJSON

  action_fallback ChronoPulseWeb.FallbackController

  # List all leave requests
  def index(conn, _params) do
    requests = Leave.list_leave_requests()
    json(conn, LeaveRequestJSON.index(%{leave_requests: requests}))
  end

  # Create a new leave request (default pending)
  def create(conn, %{"leave_request" => params}) do
    with {:ok, %LeaveRequestApproval{} = request} <- Leave.create_leave_request(params) do
      json(conn, LeaveRequestJSON.show(%{leave_request: request}))
    end
  end

  # Update a leave request (approve/reject)
  def update(conn, %{"id" => id, "leave_request" => params}) do
    request = Leave.get_leave_request!(id)

    case Leave.update_leave_request(request, params) do
      {:ok, {:ok, updated}} ->
        # When using Repo.transaction, we unwrap nested {:ok, {:ok, struct}}
        json(conn, LeaveRequestJSON.show(%{leave_request: updated}))

      {:ok, updated} ->
        # In case future code returns a simple {:ok, struct}
        json(conn, LeaveRequestJSON.show(%{leave_request: updated}))

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: inspect(reason)})
    end
  end

  # Delete a leave request
  def delete(conn, %{"id" => id}) do
    request = Leave.get_leave_request!(id)

    with {:ok, _} <- Leave.delete_leave_request(request) do
      send_resp(conn, :no_content, "")
    end
  end
end
