defmodule ChronoPulseWeb.AttendanceJSON do
  alias ChronoPulse.Attendance.Attendance

  # Accept plural key :attendances
  def index(%{attendances: records}) do
    %{data: Enum.map(records, &data/1)}
  end

  # Accept singular key :attendance
  def show(%{attendance: record}) do
    %{data: data(record)}
  end

  defp data(%Attendance{} = record) do
    %{
      id: record.id,
      user_id: record.user_id,
      date: record.date,
      status: record.status,
      inserted_at: record.inserted_at,
      updated_at: record.updated_at
    }
  end
end
