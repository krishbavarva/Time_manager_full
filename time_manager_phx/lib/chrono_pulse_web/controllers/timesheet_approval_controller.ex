defmodule ChronoPulseWeb.TimesheetApprovalController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.TimeTracking
  alias ChronoPulse.TimeTracking.WorkingTime

  action_fallback ChronoPulseWeb.FallbackController

  # GET /api/timesheet_approvals
  def index(conn, _params) do
    # Get pending timesheets for approval
    pending_timesheets = TimeTracking.list_workingtimes()
    |> Enum.filter(&(&1.status == "pending"))
    
    render(conn, :index, timesheet_approvals: pending_timesheets)
  end

  # GET /api/timesheet_approvals/:id
  def show(conn, %{"id" => id}) do
    timesheet = TimeTracking.get_working_time!(id)
    render(conn, :show, timesheet_approval: timesheet)
  end

  # POST /api/timesheet_approvals/:id/approve
  def approve(conn, %{"id" => id} = params) do
    timesheet = TimeTracking.get_working_time!(id)
    approver_id = conn.assigns.current_user.id
    notes = params["notes"] || ""
    
    approval_attrs = %{
      "status" => "approved",
      "approved_by" => approver_id
    }
    
    with {:ok, %WorkingTime{} = updated_timesheet} <- TimeTracking.update_working_time(timesheet, approval_attrs) do
      render(conn, :show, timesheet_approval: updated_timesheet)
    end
  end

  # POST /api/timesheet_approvals/:id/reject
  def reject(conn, %{"id" => id} = params) do
    timesheet = TimeTracking.get_working_time!(id)
    approver_id = conn.assigns.current_user.id
    notes = params["notes"] || ""
    
    rejection_attrs = %{
      "status" => "rejected",
      "approved_by" => approver_id
    }
    
    with {:ok, %WorkingTime{} = updated_timesheet} <- TimeTracking.update_working_time(timesheet, rejection_attrs) do
      render(conn, :show, timesheet_approval: updated_timesheet)
    end
  end
end
