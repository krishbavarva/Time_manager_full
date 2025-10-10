defmodule ChronoPulse.TimeTracking.NightShiftMonitor do
  @moduledoc """
  Service for monitoring night shifts and sending alerts.
  """

  alias ChronoPulse.TimeTracking

  @doc """
  Check if work time falls between 10 PM - 6 AM (night shift hours).
  """
  def is_night_shift?(start_time, end_time) do
    start_hour = DateTime.to_time(start_time).hour
    end_hour = DateTime.to_time(end_time).hour
    
    # Night shift is between 22:00 (10 PM) and 06:00 (6 AM)
    start_hour >= 22 or start_hour < 6 or end_hour >= 22 or end_hour < 6
  end

  @doc """
  Count consecutive night shifts for a user.
  """
  def count_consecutive_night_shifts(user_id, start_date \\ Date.utc_today()) do
    # Get working times for the past 7 days
    end_date = Date.add(start_date, -7)
    
    working_times = TimeTracking.list_workingtimes()
    |> Enum.filter(&(&1.user_id == user_id))
    |> Enum.filter(fn wt ->
      wt_date = DateTime.to_date(wt.start)
      Date.compare(wt_date, end_date) >= 0 and Date.compare(wt_date, start_date) <= 0
    end)
    |> Enum.sort_by(& &1.start, {:desc, DateTime})

    count_consecutive_nights(working_times, 0)
  end

  @doc """
  Check if user has exceeded night shift limit and send alert if needed.
  """
  def check_night_shift_limit(user_id, limit \\ 5) do
    consecutive_nights = count_consecutive_night_shifts(user_id)
    
    if consecutive_nights >= limit do
      # Send alert notification
      send_night_shift_alert(user_id, consecutive_nights)
      {:alert, consecutive_nights}
    else
      {:ok, consecutive_nights}
    end
  end

  # Private functions

  defp count_consecutive_nights([], count), do: count
  
  defp count_consecutive_nights([wt | rest], count) do
    if is_night_shift?(wt.start, wt.end) do
      count_consecutive_nights(rest, count + 1)
    else
      count
    end
  end

  defp send_night_shift_alert(user_id, consecutive_nights) do
    # This would integrate with a notification system
    # For now, just log the alert
    require Logger
    Logger.warning("User #{user_id} has worked #{consecutive_nights} consecutive night shifts")
    
    # TODO: Send email/SMS notification
    # TODO: Create notification record in database
  end
end
