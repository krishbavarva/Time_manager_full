defmodule ChronoPulseWeb.AttendanceController do
  use ChronoPulseWeb, :controller

  # Context module (renamed to avoid conflict with schema)
  alias ChronoPulse.Attendance, as: AttendanceContext

  # Schema module
  alias ChronoPulse.Attendance.Attendance

  # JSON rendering module
  alias ChronoPulseWeb.AttendanceJSON

  action_fallback ChronoPulseWeb.FallbackController

  # GET /api/attendance
  def index(conn, _params) do
    attendances = AttendanceContext.list_attendance()
    json(conn, AttendanceJSON.index(%{attendances: attendances}))
  end

  # POST /api/attendance
  def create(conn, %{"attendance" => attendance_params}) do
    with {:ok, %Attendance{} = attendance} <- AttendanceContext.create_attendance(attendance_params) do
      json(conn, AttendanceJSON.show(%{attendance: attendance}))
    end
  end

  # GET /api/attendance/:id
  def show(conn, %{"id" => id}) do
    attendance = AttendanceContext.get_attendance!(id)
    json(conn, AttendanceJSON.show(%{attendance: attendance}))
  end

  # PUT or PATCH /api/attendance/:id
  def update(conn, %{"id" => id, "attendance" => attendance_params}) do
    attendance = AttendanceContext.get_attendance!(id)

    with {:ok, %Attendance{} = updated} <- AttendanceContext.update_attendance(attendance, attendance_params) do
      json(conn, AttendanceJSON.show(%{attendance: updated}))
    end
  end

  # DELETE /api/attendance/:id
  def delete(conn, %{"id" => id}) do
    attendance = AttendanceContext.get_attendance!(id)

    with {:ok, %Attendance{}} <- AttendanceContext.delete_attendance(attendance) do
      send_resp(conn, :no_content, "")
    end
  end
end
