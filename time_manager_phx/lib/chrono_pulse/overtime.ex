defmodule ChronoPulse.Overtime do
  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.Overtime.OvertimeRequest

  def list_requests do
    Repo.all(OvertimeRequest) |> Repo.preload(:user)
  end

  def get_request!(id), do: Repo.get!(OvertimeRequest, id) |> Repo.preload(:user)

  def create_request(attrs) do
    %OvertimeRequest{}
    |> OvertimeRequest.changeset(attrs)
    |> Repo.insert()
  end

  def update_request(%OvertimeRequest{} = request, attrs) do
    request
    |> OvertimeRequest.changeset(attrs)
    |> Repo.update()
  end

  def delete_request(%OvertimeRequest{} = request) do
    Repo.delete(request)
  end
end
