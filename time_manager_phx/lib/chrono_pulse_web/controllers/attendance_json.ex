defmodule ChronoPulseWeb.AttendanceJSON do
  @doc """
  Renders a list of attendances.
  """
  def index(%{attendances: attendances}) do
    %{data: for(attendance <- attendances, do: data(attendance))}
  end

  @doc """
  Renders a single attendance.
  """
  def show(%{attendance: attendance}) do
    %{data: data(attendance)}
  end

  defp data(%ChronoPulse.Attendance.Attendance{} = attendance) do
    %{
      id: attendance.id,
      user_id: attendance.user_id,
      date: attendance.date,
      status: attendance.status,
      inserted_at: attendance.inserted_at,
      updated_at: attendance.updated_at
    }
  end

  defp data(%{} = attendance) when is_map(attendance) do
    %{
      id: attendance.id,
      user_id: attendance.user_id,
      date: attendance.date,
      status: attendance.status,
      inserted_at: attendance.inserted_at,
      updated_at: attendance.updated_at,
      user_name: attendance.user_name,
      user_email: attendance.user_email,
      user_role: attendance.user_role
    }
  end
end
