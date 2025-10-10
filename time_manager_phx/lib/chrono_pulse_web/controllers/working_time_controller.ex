defmodule ChronoPulseWeb.WorkingTimeController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.TimeTracking
  alias ChronoPulse.TimeTracking.WorkingTime

  action_fallback ChronoPulseWeb.FallbackController

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

  # GET /api/workingtime/:userID?start=XXX&end=YYY
  def index(conn, params) do
    user_id = Map.get(params, "user_id")
    start_str = Map.get(params, "start")
    end_str = Map.get(params, "end")
    
    base = TimeTracking.list_workingtimes()
    |> Enum.filter(&(&1.user_id == user_id))
    |> Enum.sort_by(& &1.start)

    # Apply date filtering if parameters are provided
    list = case {start_str, end_str} do
      {nil, nil} -> base
      {s, nil} ->
        case parse_date(s) do
          {:ok, sdt} -> Enum.filter(base, &DateTime.compare(&1.start, sdt) != :lt)
          {:error, _} -> base
        end
      {nil, e} ->
        case parse_date(e) do
          {:ok, edt} -> Enum.filter(base, &DateTime.compare(&1.end, edt) != :gt)
          {:error, _} -> base
        end
      {s, e} ->
        case {parse_date(s), parse_date(e)} do
          {{:ok, sdt}, {:ok, edt}} ->
            Enum.filter(base, fn w -> DateTime.compare(w.start, sdt) != :lt and DateTime.compare(w.end, edt) != :gt end)
          _ -> base
        end
    end
    
    render(conn, :index, workingtimes: list)
  end

  # POST /api/workingtime/:userID
  def create(conn, %{"user_id" => user_id, "working_time" => working_time_params}) do
    working_time_params = Map.put(working_time_params, "user_id", user_id)
    with {:ok, %WorkingTime{} = working_time} <- TimeTracking.create_working_time(working_time_params) do
      conn
      |> put_status(:created)
      |> render(:show, working_time: working_time)
    end
  end

  # GET /api/workingtime/:userID/:id
  def show(conn, %{"user_id" => user_id, "id" => id}) do
    working_time = TimeTracking.get_working_time!(id)
    if working_time.user_id != user_id, do: send_resp(conn, :not_found, ""), else: render(conn, :show, working_time: working_time)
  end

  def update(conn, %{"id" => id, "working_time" => working_time_params}) do
    working_time = TimeTracking.get_working_time!(id)

    with {:ok, %WorkingTime{} = working_time} <- TimeTracking.update_working_time(working_time, working_time_params) do
      render(conn, :show, working_time: working_time)
    end
  end

  def delete(conn, %{"id" => id}) do
    working_time = TimeTracking.get_working_time!(id)

    with {:ok, %WorkingTime{}} <- TimeTracking.delete_working_time(working_time) do
      send_resp(conn, :no_content, "")
    end
  end
end
