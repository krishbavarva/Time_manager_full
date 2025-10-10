defmodule ChronoPulse.Teams.Team do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]  # <- import from/2
  alias ChronoPulse.Accounts.User
  alias ChronoPulse.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "teams" do
    field :description, :string

    belongs_to :manager, User, type: :binary_id
    many_to_many :employees, User,
      join_through: "teams_employees",
      join_keys: [team_id: :id, employee_id: :id],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:description, :manager_id])
    |> validate_required([:description])
    |> assoc_constraint(:manager)
    |> put_employees_assoc(attrs)
  end

  # Associate employees using employee_ids
  defp put_employees_assoc(changeset, %{"employee_ids" => employee_ids}) when is_list(employee_ids) do
    employees =
      from(u in User, where: u.id in ^employee_ids)  # <- use ^ inside a query
      |> Repo.all()

    put_assoc(changeset, :employees, employees)
  end

  defp put_employees_assoc(changeset, _), do: changeset
end
