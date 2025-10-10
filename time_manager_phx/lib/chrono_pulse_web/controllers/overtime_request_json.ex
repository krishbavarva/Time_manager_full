defmodule ChronoPulseWeb.OvertimeRequestJSON do
  @doc """
  Renders a list of overtime requests.
  """
  def index(%{overtime_requests: overtime_requests}) do
    %{data: for(overtime_request <- overtime_requests, do: data(overtime_request))}
  end

  @doc """
  Renders a single overtime request.
  """
  def show(%{overtime_request: overtime_request}) do
    %{data: data(overtime_request)}
  end

  defp data(%ChronoPulse.Overtime.OvertimeRequest{} = overtime_request) do
    %{
      id: overtime_request.id,
      user_id: overtime_request.user_id,
      hours: overtime_request.hours,
      reason: overtime_request.reason,
      status: overtime_request.status,
      inserted_at: overtime_request.inserted_at,
      updated_at: overtime_request.updated_at
    }
  end
end
