defmodule ChronoPulseWeb.UserScheduleController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.TimeTracking
  alias ChronoPulse.TimeTracking.UserSchedule

  action_fallback ChronoPulseWeb.FallbackController

  # GET /api/user_schedules?user_id=XXX
  def index(conn, params) do
    user_id = Map.get(params, "user_id")
    user_schedules = if user_id do
      TimeTracking.list_user_schedules(user_id)
    else
      []
    end
    render(conn, :index, user_schedules: user_schedules)
  end

  # GET /api/user_schedules/:id
  def show(conn, %{"id" => id}) do
    user_schedule = TimeTracking.get_user_schedule!(id)
    render(conn, :show, user_schedule: user_schedule)
  end

  # POST /api/user_schedules
  def create(conn, %{"user_schedule" => user_schedule_params}) do
    # user_id should be included in the user_schedule_params from frontend
    with {:ok, %UserSchedule{} = user_schedule} <- TimeTracking.create_user_schedule(user_schedule_params) do
      conn
      |> put_status(:created)
      |> render(:show, user_schedule: user_schedule)
    end
  end

  # PUT/PATCH /api/user_schedules/:id
  def update(conn, %{"id" => id, "user_schedule" => user_schedule_params}) do
    user_schedule = TimeTracking.get_user_schedule!(id)

    with {:ok, %UserSchedule{} = user_schedule} <- TimeTracking.update_user_schedule(user_schedule, user_schedule_params) do
      render(conn, :show, user_schedule: user_schedule)
    end
  end

  # DELETE /api/user_schedules/:id
  def delete(conn, %{"id" => id}) do
    user_schedule = TimeTracking.get_user_schedule!(id)

    with {:ok, %UserSchedule{}} <- TimeTracking.delete_user_schedule(user_schedule) do
      send_resp(conn, :no_content, "")
    end
  end

  # GET /api/user_schedules/user/:user_id
  def by_user(conn, %{"user_id" => user_id}) do
    user_schedules = TimeTracking.list_user_schedules(user_id)
    render(conn, :index, user_schedules: user_schedules)
  end
end
