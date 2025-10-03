defmodule ChronoPulse.Teams do
  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.Teams.Team
  alias ChronoPulse.Accounts.User

  # List all teams with preloaded employees and manager
  def list_teams do
    Repo.all(Team)
    |> Repo.preload([:manager, :employees])
  end

  # Get single team by id with associations
  def get_team!(id) do
    Repo.get!(Team, id)
    |> Repo.preload([:manager, :employees])
  end

  # Get all teams managed by a given user
  def list_teams_by_manager(manager_id) do
    Team
    |> where([t], t.manager_id == ^manager_id)
    |> Repo.all()
    |> Repo.preload([:manager, :employees])
  end

  # (Optional) Get all teams where a user is an employee
  def list_teams_by_employee(employee_id) do
    Team
    |> join(:inner, [t], e in assoc(t, :employees))
    |> where([_t, e], e.id == ^employee_id)
    |> Repo.all()
    |> Repo.preload([:manager, :employees])
  end

  # Create team and preload associations
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, team} -> {:ok, Repo.preload(team, [:manager, :employees])}
      error -> error
    end
  end

  # Update team and preload associations
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, team} -> {:ok, Repo.preload(team, [:manager, :employees])}
      error -> error
    end
  end

  # Delete team
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  # Add employee to team
  def add_employee(team, %User{} = employee) do
    team
    |> Repo.preload(:employees)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:employees, [employee | team.employees])
    |> Repo.update()
    |> case do
      {:ok, team} -> {:ok, Repo.preload(team, [:manager, :employees])}
      error -> error
    end
  end

  # Remove employee from team
  def remove_employee(team, %User{} = employee) do
    team
    |> Repo.preload(:employees)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:employees, List.delete(team.employees, employee))
    |> Repo.update()
    |> case do
      {:ok, team} -> {:ok, Repo.preload(team, [:manager, :employees])}
      error -> error
    end
  end
end
