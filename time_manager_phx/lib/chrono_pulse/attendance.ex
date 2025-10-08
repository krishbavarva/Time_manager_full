defmodule ChronoPulse.Attendance do
  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.Attendance.Attendance

  def list_attendance do
    Repo.all(Attendance)
  end

  def get_attendance!(id), do: Repo.get!(Attendance, id)

  def create_attendance(attrs \\ %{}) do
    %Attendance{}
    |> Attendance.changeset(attrs)
    |> Repo.insert()
  end

  def update_attendance(%Attendance{} = attendance, attrs) do
    attendance
    |> Attendance.changeset(attrs)
    |> Repo.update()
  end

  def delete_attendance(%Attendance{} = attendance) do
    Repo.delete(attendance)
  end
end
