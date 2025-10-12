defmodule ChronoPulseWeb.LeaveRequestController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.Leave
  alias ChronoPulse.Leave.LeaveRequest
  alias ChronoPulse.Repo

  action_fallback ChronoPulseWeb.FallbackController

  # List all leave requests (for admin)
  def index(conn, _params) do
    current_user = conn.assigns[:current_user]
    
    # Only admins can see all requests
    if current_user.role == "admin" do
      requests = Leave.list_leave_requests()
      render(conn, :index, leave_requests: requests)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end

  # List leave requests for a specific user
  def user_requests(conn, %{"user_id" => user_id}) do
    current_user = conn.assigns[:current_user]
    
    # Users can only see their own requests, admins can see any user's requests
    if current_user.id == user_id or current_user.role == "admin" do
      requests = Leave.list_leave_requests_by_user(user_id)
      render(conn, :index, leave_requests: requests)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end

  # Create a new leave request
  def create(conn, %{"leave_request" => params}) do
    current_user = conn.assigns[:current_user]
    
    # Add current user ID to params
    params = Map.put(params, "user_id", current_user.id)
    
    with {:ok, %LeaveRequest{} = leave_request} <- Leave.create_leave_request(params) do
      leave_request = Repo.preload(leave_request, [:user, :approved_by])
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/leave_requests/#{leave_request.id}")
      |> render(:show, leave_request: leave_request)
    end
  end

  # Show a specific leave request
  def show(conn, %{"id" => id}) do
    current_user = conn.assigns[:current_user]
    leave_request = Leave.get_leave_request!(id)
    
    # Users can only see their own requests, admins can see any request
    if leave_request.user_id == current_user.id or current_user.role == "admin" do
      render(conn, :show, leave_request: leave_request)
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end

  # Update a leave request (only for pending requests by the user)
  def update(conn, %{"id" => id, "leave_request" => params}) do
    current_user = conn.assigns[:current_user]
    leave_request = Leave.get_leave_request!(id)
    
    # Only the user can update their own pending requests
    if leave_request.user_id == current_user.id and leave_request.status == "pending" do
      # Remove fields that shouldn't be updated by users
      params = Map.drop(params, ["status", "approved_by_id", "admin_notes"])
      
      with {:ok, %LeaveRequest{} = leave_request} <- Leave.update_leave_request(leave_request, params) do
        leave_request = Repo.preload(leave_request, [:user, :approved_by])
        render(conn, :show, leave_request: leave_request)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Cannot update this leave request"})
    end
  end

  # Approve a leave request (admin only)
  def approve(conn, %{"id" => id, "leave_request" => params}) do
    current_user = conn.assigns[:current_user]
    
    if current_user.role == "admin" do
      leave_request = Leave.get_leave_request!(id)
      admin_notes = Map.get(params, "admin_notes")
      
      with {:ok, %LeaveRequest{} = leave_request} <- Leave.approve_leave_request(leave_request, current_user.id, admin_notes) do
        leave_request = Repo.preload(leave_request, [:user, :approved_by])
        render(conn, :show, leave_request: leave_request)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end

  # Reject a leave request (admin only)
  def reject(conn, %{"id" => id, "leave_request" => params}) do
    current_user = conn.assigns[:current_user]
    
    if current_user.role == "admin" do
      leave_request = Leave.get_leave_request!(id)
      admin_notes = Map.get(params, "admin_notes")
      
      with {:ok, %LeaveRequest{} = leave_request} <- Leave.reject_leave_request(leave_request, current_user.id, admin_notes) do
        leave_request = Repo.preload(leave_request, [:user, :approved_by])
        render(conn, :show, leave_request: leave_request)
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Access denied"})
    end
  end

  # Delete a leave request (only pending requests by the user)
  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns[:current_user]
    leave_request = Leave.get_leave_request!(id)
    
    # Only the user can delete their own pending requests
    if leave_request.user_id == current_user.id and leave_request.status == "pending" do
      with {:ok, %LeaveRequest{}} <- Leave.delete_leave_request(leave_request) do
        send_resp(conn, :no_content, "")
      end
    else
      conn
      |> put_status(:forbidden)
      |> json(%{error: "Cannot delete this leave request"})
    end
  end
end