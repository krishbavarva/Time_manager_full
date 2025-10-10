defmodule ChronoPulseWeb.TimesheetApprovalJSON do
  alias ChronoPulse.TimeTracking.WorkingTime

  def index(%{timesheet_approvals: timesheet_approvals}) do
    %{data: for(timesheet <- timesheet_approvals, do: data(timesheet))}
  end

  def show(%{timesheet_approval: timesheet_approval}) do
    %{data: data(timesheet_approval)}
  end

  defp data(%WorkingTime{} = timesheet) do
    %{
      id: timesheet.id,
      user_id: timesheet.user_id,
      start: timesheet.start,
      end: timesheet.end,
      scheduled_hours: timesheet.scheduled_hours,
      actual_hours: timesheet.actual_hours,
      break_hours: timesheet.break_hours,
      overtime_hours: timesheet.overtime_hours,
      status: timesheet.status,
      approved_by: timesheet.approved_by,
      inserted_at: timesheet.inserted_at,
      updated_at: timesheet.updated_at
    }
  end
end
