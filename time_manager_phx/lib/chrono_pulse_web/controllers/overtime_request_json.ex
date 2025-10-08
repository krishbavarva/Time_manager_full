defmodule ChronoPulseWeb.OvertimeRequestJSON do
  alias ChronoPulse.Overtime.OvertimeRequest

  def index(%{requests: requests}) do
    %{data: (for req <- requests, do: data(req))}
  end

  def show(%{request: request}) do
    %{data: data(request)}
  end

  defp data(%OvertimeRequest{} = request) do
    %{
      id: request.id,
      user_id: request.user_id,
      hours: request.hours,
      reason: request.reason,
      status: request.status,
      inserted_at: request.inserted_at,
      updated_at: request.updated_at
    }
  end
end
