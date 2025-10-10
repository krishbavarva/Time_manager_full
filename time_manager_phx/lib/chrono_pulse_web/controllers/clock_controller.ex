defmodule ChronoPulseWeb.ClockController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.TimeTracking
  alias ChronoPulse.TimeTracking.BreakCalculator
  # GET /api/clocks/:userID
  def index(conn, %{"user_id" => user_id} = params) do
    require Logger
    
    clocks = case {Map.get(params, "start"), Map.get(params, "end")} do
      {nil, nil} -> 
        TimeTracking.list_clocks_for_user(user_id)
      {start_str, end_str} ->
        case {parse_date(start_str), parse_date(end_str)} do
          {{:ok, start_dt}, {:ok, end_dt}} ->
            TimeTracking.list_clocks_for_user(user_id)
            |> Enum.filter(fn clock -> 
              DateTime.compare(clock.time, start_dt) != :lt and 
              DateTime.compare(clock.time, end_dt) != :gt
            end)
          _ ->
            TimeTracking.list_clocks_for_user(user_id)
        end
    end
    
    Logger.info("Returning #{length(clocks)} clock records for user #{user_id}")
    render(conn, :index, clocks: clocks)
  end

  # POST /api/clocks/:userID -> toggles arrival/departure with optional location
  def create(conn, %{"user_id" => user_id} = params) do
    require Logger
    Logger.info("Received clock request with params: #{inspect(params)}")
    
    last = TimeTracking.last_clock_for_user(user_id)
    next_status = if last && last.status, do: false, else: true
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    
    clock_attrs = %{
      "user_id" => user_id,
      "status" => next_status,
      "time" => now,
      "latitude" => params["latitude"],
      "longitude" => params["longitude"]
    }
    
    Logger.info("Creating clock with attrs: #{inspect(clock_attrs)}")
    
    with {:ok, clock} <- TimeTracking.create_clock(clock_attrs) do
      # When toggling OUT and previous clock was IN, create a working time session with break calculation
      if last && last.status == true && next_status == false do
        # Calculate break time and actual working time for the day
        date = DateTime.to_date(now)
        {working_hours, break_hours, _clock_pairs} = BreakCalculator.calculate_breaks_for_day(user_id, date)
        
        # Get scheduled hours for the day
        day_of_week = Date.day_of_week(date) |> day_name_from_number()
        scheduled_hours = case TimeTracking.get_schedule_for_day(user_id, day_of_week) do
          nil -> 8.0  # Default 8 hours if no schedule set
          schedule -> schedule.scheduled_hours
        end
        
        # Calculate overtime
        overtime_hours = max(0, working_hours - scheduled_hours)
        
        working_time_attrs = %{
          "user_id" => user_id, 
          "start" => last.time, 
          "end" => now,
          "scheduled_hours" => scheduled_hours,
          "actual_hours" => working_hours,
          "break_hours" => break_hours,
          "overtime_hours" => overtime_hours
        }
        
        TimeTracking.create_working_time(working_time_attrs)
      end

      conn
      |> put_status(:created)
      |> render(:show, clock: clock)
    end
  end

  defp parse_date(date_str) when is_binary(date_str) do
    # Remove milliseconds if present and ensure Z suffix
    clean_date = date_str
    |> String.replace(~r/\.\d{3}Z$/, "Z")
    |> then(fn d -> if String.ends_with?(d, "Z"), do: d, else: d <> "Z" end)
    
    case DateTime.from_iso8601(clean_date) do
      {:ok, dt, _} -> {:ok, dt}
      {:error, reason} -> {:error, reason}
    end
  end

  # Helper function to convert day number to day name
  defp day_name_from_number(1), do: "monday"
  defp day_name_from_number(2), do: "tuesday"
  defp day_name_from_number(3), do: "wednesday"
  defp day_name_from_number(4), do: "thursday"
  defp day_name_from_number(5), do: "friday"
  defp day_name_from_number(6), do: "saturday"
  defp day_name_from_number(7), do: "sunday"
end



