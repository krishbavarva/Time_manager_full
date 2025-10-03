defmodule ChronoPulseWeb.TeamJSON do
  alias ChronoPulse.Teams.Team

  @doc """
  Renders a list of teams.
  """
  def index(%{teams: teams}) do
    %{data: Enum.map(teams, &data/1)}
  end

  @doc """
  Renders a single team.
  """
  def show(%{team: team}) do
    %{data: data(team)}
  end

  defp data(%Team{} = team) do
    %{
      id: team.id,
      description: team.description,
      manager: %{
        id: team.manager.id,
        username: team.manager.username,
        email: team.manager.email
      },
      employees: Enum.map(team.employees, fn emp ->
        %{
          id: emp.id,
          username: emp.username,
          email: emp.email
        }
      end)
    }
  end
end
