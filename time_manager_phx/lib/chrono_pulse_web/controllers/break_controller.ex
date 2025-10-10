defmodule ChronoPulseWeb.BreakController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.TimeTracking.BreakCalculator

  action_fallback ChronoPulseWeb.FallbackController

  # GET /api/breaks/user/:user_id/date/:date
  def calculate(conn, %{"user_id" => user_id, "date" => date_str}) do
    case Date.from_iso8601(date_str) do
      {:ok, date} ->
        {working_hours, break_hours, clock_pairs} = BreakCalculator.calculate_breaks_for_day(user_id, date)
        
        json(conn, %{
          user_id: user_id,
          date: date,
          working_hours: working_hours,
          break_hours: break_hours,
          clock_pairs: clock_pairs
        })
      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid date format. Use YYYY-MM-DD"})
    end
  end
end
