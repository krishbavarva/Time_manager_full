defmodule ChronoPulseWeb.OvertimeRequestController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.Overtime
  alias ChronoPulse.Overtime.OvertimeRequest
  alias ChronoPulseWeb.OvertimeRequestJSON

  action_fallback ChronoPulseWeb.FallbackController

  # GET /api/overtime_requests
  def index(conn, _params) do
    requests = Overtime.list_requests()
    json(conn, OvertimeRequestJSON.index(%{overtime_requests: requests}))
  end

  # GET /api/overtime_requests/:id
  def show(conn, %{"id" => id}) do
    request = Overtime.get_request!(id)
    json(conn, OvertimeRequestJSON.show(%{overtime_request: request}))
  end

  # POST /api/overtime_requests
  def create(conn, %{"overtime_request" => request_params}) do
    with {:ok, %OvertimeRequest{} = request} <- Overtime.create_request(request_params) do
      conn
      |> put_status(:created)
      |> json(OvertimeRequestJSON.show(%{overtime_request: request}))
    end
  end

  # PUT/PATCH /api/overtime_requests/:id
  def update(conn, %{"id" => id, "overtime_request" => request_params}) do
    request = Overtime.get_request!(id)

    with {:ok, %OvertimeRequest{} = updated_request} <- Overtime.update_request(request, request_params) do
      json(conn, OvertimeRequestJSON.show(%{overtime_request: updated_request}))
    end
  end

  # DELETE /api/overtime_requests/:id
  def delete(conn, %{"id" => id}) do
    request = Overtime.get_request!(id)

    with {:ok, %OvertimeRequest{}} <- Overtime.delete_request(request) do
      send_resp(conn, :no_content, "")
    end
  end
end
