defmodule ChronoPulseWeb.UserScheduleJSON do
  alias ChronoPulse.TimeTracking.UserSchedule

  def index(%{user_schedules: user_schedules}) do
    %{data: for(user_schedule <- user_schedules, do: data(user_schedule))}
  end

  def show(%{user_schedule: user_schedule}) do
    %{data: data(user_schedule)}
  end

  defp data(%UserSchedule{} = user_schedule) do
    %{
      id: user_schedule.id,
      user_id: user_schedule.user_id,
      day_of_week: user_schedule.day_of_week,
      scheduled_start_time: user_schedule.scheduled_start_time,
      scheduled_end_time: user_schedule.scheduled_end_time,
      scheduled_hours: user_schedule.scheduled_hours,
      is_active: user_schedule.is_active,
      inserted_at: user_schedule.inserted_at,
      updated_at: user_schedule.updated_at
    }
  end
end
