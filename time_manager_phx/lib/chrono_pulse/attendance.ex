defmodule ChronoPulse.Attendance do
  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.Attendance.Attendance

  def list_attendance do
    Attendance
    |> join(:left, [a], u in assoc(a, :user))
    |> select([a, u], %{
      id: a.id,
      user_id: a.user_id,
      date: a.date,
      status: a.status,
      inserted_at: a.inserted_at,
      updated_at: a.updated_at,
      user_name: fragment("COALESCE(?, '') || ' ' || COALESCE(?, '')", u.first_name, u.last_name),
      user_email: u.email,
      user_role: u.role
    })
    |> Repo.all()
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
