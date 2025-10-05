defmodule ChronoPulseWeb.ClockController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.TimeTracking
  # GET /api/clocks/:userID
  def index(conn, %{"user_id" => user_id}) do
    require Logger
    clocks = TimeTracking.list_clocks_for_user(user_id)
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
      # When toggling OUT and previous clock was IN, create a working time session
      if last && last.status == true && next_status == false do
        TimeTracking.create_working_time(%{"user_id" => user_id, "start" => last.time, "end" => now})
      end

      conn
      |> put_status(:created)
      |> render(:show, clock: clock)
    end
  end
end



