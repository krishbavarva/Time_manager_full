defmodule ChronoPulse.TimeTracking.BreakCalculator do
  @moduledoc """
  Service for calculating break times from clock-in/out records.
  """

  alias ChronoPulse.TimeTracking

  @doc """
  Calculate working hours and break hours for a specific day based on clock records.
  
  Returns: `{working_hours, break_hours, clock_pairs}`
  """
  def calculate_breaks_for_day(user_id, date) do
    # Get all clock records for the day
    clocks = TimeTracking.list_clocks_for_user_on_date_asc(user_id, date)
    |> Enum.sort_by(& &1.time)

    {working_hours, break_hours, clock_pairs} = 
      clocks
      |> pair_clock_records()
      |> calculate_time_periods()

    {working_hours, break_hours, clock_pairs}
  end

  @doc """
  Calculate breaks for a date range.
  """
  def calculate_breaks_for_range(_user_id, _start_date, _end_date) do
    # This would be implemented to calculate breaks across multiple days
    # For now, return empty results
    {0.0, 0.0, []}
  end

  # Private functions

  defp pair_clock_records(clocks) do
    clocks
    |> Enum.chunk_every(2)
    |> Enum.map(fn
      [clock_in, clock_out] when clock_in.status == true and clock_out.status == false ->
        {:working_period, clock_in, clock_out}
      [clock_out, clock_in] when clock_out.status == false and clock_in.status == true ->
        {:break_period, clock_out, clock_in}
      _ ->
        nil
    end)
    |> Enum.filter(& &1)
  end

  defp calculate_time_periods(clock_pairs) do
    {working_hours, break_hours} = 
      Enum.reduce(clock_pairs, {0.0, 0.0}, fn
        {:working_period, clock_in, clock_out}, {w_acc, b_acc} ->
          duration = calculate_duration(clock_in.time, clock_out.time)
          {w_acc + duration, b_acc}
        {:break_period, clock_out, clock_in}, {w_acc, b_acc} ->
          duration = calculate_duration(clock_out.time, clock_in.time)
          {w_acc, b_acc + duration}
      end)

    {working_hours, break_hours, clock_pairs}
  end

  defp calculate_duration(start_time, end_time) do
    DateTime.diff(end_time, start_time, :second) / 3600.0
  end
end
