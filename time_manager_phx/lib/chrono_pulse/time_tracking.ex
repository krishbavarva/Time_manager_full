defmodule ChronoPulse.TimeTracking do
  @moduledoc """
  The TimeTracking context.
  """

  import Ecto.Query, warn: false
  alias ChronoPulse.Repo

  alias ChronoPulse.TimeTracking.WorkingTime
  alias ChronoPulse.TimeTracking.Clock
  alias ChronoPulse.TimeTracking.UserSchedule

  @doc """
  Returns the list of workingtimes.

  ## Examples

      iex> list_workingtimes()
      [%WorkingTime{}, ...]

  """
  def list_workingtimes do
    Repo.all(WorkingTime)
  end

  @doc """
  Gets a single working_time.

  Raises `Ecto.NoResultsError` if the Working time does not exist.

  ## Examples

      iex> get_working_time!(123)
      %WorkingTime{}

      iex> get_working_time!(456)
      ** (Ecto.NoResultsError)

  """
  def get_working_time!(id), do: Repo.get!(WorkingTime, id)

  @doc """
  Creates a working_time.

  ## Examples

      iex> create_working_time(%{field: value})
      {:ok, %WorkingTime{}}

      iex> create_working_time(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_working_time(attrs) do
    %WorkingTime{}
    |> WorkingTime.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a working_time.

  ## Examples

      iex> update_working_time(working_time, %{field: new_value})
      {:ok, %WorkingTime{}}

      iex> update_working_time(working_time, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_working_time(%WorkingTime{} = working_time, attrs) do
    working_time
    |> WorkingTime.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a working_time.

  ## Examples

      iex> delete_working_time(working_time)
      {:ok, %WorkingTime{}}

      iex> delete_working_time(working_time)
      {:error, %Ecto.Changeset{}}

  """
  def delete_working_time(%WorkingTime{} = working_time) do
    Repo.delete(working_time)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking working_time changes.

  ## Examples

      iex> change_working_time(working_time)
      %Ecto.Changeset{data: %WorkingTime{}}

  """
  def change_working_time(%WorkingTime{} = working_time, attrs \\ %{}) do
    WorkingTime.changeset(working_time, attrs)
  end

  # Clocks
  def list_clocks_for_user(user_id) do
    Repo.all(from c in Clock, where: c.user_id == ^user_id, order_by: [desc: c.time])
  end

  @doc """
  Same as listing clocks but limited to a specific date and ordered ascending by time.
  Useful for computing breaks between OUT/IN pairs within the day.
  """
  def list_clocks_for_user_on_date_asc(user_id, %Date{} = date) do
    {:ok, start_dt} = DateTime.new(date, ~T[00:00:00], "Etc/UTC")
    {:ok, end_dt} = DateTime.new(date, ~T[23:59:59], "Etc/UTC")

    Repo.all(
      from c in Clock,
        where: c.user_id == ^user_id and c.time >= ^start_dt and c.time <= ^end_dt,
        order_by: [asc: c.time]
    )
  end

  def list_clocks_for_user_on_date_asc(user_id, date_string) when is_binary(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> list_clocks_for_user_on_date_asc(user_id, date)
      _ -> []
    end
  end

  def create_clock(attrs) do
    %Clock{}
    |> Clock.changeset(attrs)
    |> Repo.insert()
  end

  def last_clock_for_user(user_id) do
    Repo.one(from c in Clock, where: c.user_id == ^user_id, order_by: [desc: c.time], limit: 1)
  end

  # Ascending order (oldest -> newest), useful to compute breaks between OUT/IN pairs
  def list_clocks_for_user_asc(user_id) do
    Repo.all(from c in Clock, where: c.user_id == ^user_id, order_by: [asc: c.time])
  end

  # Fetch a single clock by id (returns nil if not found)
  def get_clock(id), do: Repo.get(Clock, id)

  # Delete a clock entry
  def delete_clock(%Clock{} = clock), do: Repo.delete(clock)

  @doc """
  Deletes all time tracking data (clocks and workingtimes) for a given user.

  Returns :ok after attempting deletions.
  """
  def delete_all_for_user(user_id) do
    # Delete clocks first, then working times to satisfy any FK constraints
    Repo.delete_all(from c in Clock, where: c.user_id == ^user_id)
    Repo.delete_all(from w in WorkingTime, where: w.user_id == ^user_id)
    :ok
  end

  # User Schedule functions

  @doc """
  Creates a user schedule.
  """
  def create_user_schedule(attrs \\ %{}) do
    %UserSchedule{}
    |> UserSchedule.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single user schedule.
  """
  def get_user_schedule!(id), do: Repo.get!(UserSchedule, id)

  @doc """
  Lists all user schedules for a user.
  """
  def list_user_schedules(user_id) do
    Repo.all(from s in UserSchedule, where: s.user_id == ^user_id and s.is_active == true)
  end

  @doc """
  Gets the schedule for a specific day of the week for a user.
  """
  def get_schedule_for_day(user_id, day_of_week) do
    Repo.one(from s in UserSchedule, 
      where: s.user_id == ^user_id and s.day_of_week == ^day_of_week and s.is_active == true)
  end

  @doc """
  Updates a user schedule.
  """
  def update_user_schedule(%UserSchedule{} = user_schedule, attrs) do
    user_schedule
    |> UserSchedule.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user schedule.
  """
  def delete_user_schedule(%UserSchedule{} = user_schedule) do
    Repo.delete(user_schedule)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user schedule changes.
  """
  def change_user_schedule(%UserSchedule{} = user_schedule, attrs \\ %{}) do
    UserSchedule.changeset(user_schedule, attrs)
  end
end
