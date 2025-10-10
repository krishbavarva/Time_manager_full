defmodule ChronoPulseWeb.TeamClockController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.TimeTracking
  alias ChronoPulse.Teams

  action_fallback ChronoPulseWeb.FallbackController

  # POST /api/teams/:team_id/clock_in
  def clock_in_team(conn, %{"team_id" => team_id} = params) do
    # Get team members
    team = Teams.get_team!(team_id)
    team_members = Teams.list_team_members(team_id)
    
    # Clock in all team members
    results = Enum.map(team_members, fn member ->
      clock_attrs = %{
        "user_id" => member.user_id,
        "status" => true,
        "time" => DateTime.utc_now() |> DateTime.truncate(:second),
        "latitude" => params["latitude"],
        "longitude" => params["longitude"]
      }
      
      case TimeTracking.create_clock(clock_attrs) do
        {:ok, clock} -> {:ok, clock}
        {:error, changeset} -> {:error, changeset}
      end
    end)
    
    # Separate successful and failed clock-ins
    {successful, failed} = Enum.split_with(results, fn
      {:ok, _} -> true
      {:error, _} -> false
    end)
    
    successful_count = length(successful)
    failed_count = length(failed)
    
    conn
    |> put_status(:created)
    |> json(%{
      message: "Team clock-in completed",
      team_id: team_id,
      successful_count: successful_count,
      failed_count: failed_count,
      results: Enum.map(results, fn
        {:ok, clock} -> %{user_id: clock.user_id, status: "success"}
        {:error, _} -> %{user_id: "unknown", status: "failed"}
      end)
    })
  end
end
