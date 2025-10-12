defmodule ChronoPulse.UserComplaints do
  @moduledoc """
  The UserComplaints context.
  """

  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.UserComplaints.UserComplaint

  # Create a complaint
  def create_user_complaint(attrs \\ %{}) do
    %UserComplaint{}
    |> UserComplaint.changeset(attrs)
    |> Repo.insert()
  end

  # Get all complaints with user info
  def list_user_complaints do
    query = from c in UserComplaint,
      join: u in ChronoPulse.Accounts.User, on: c.user_id == u.id,
      select: %{
        id: c.id,
        user_id: c.user_id,
        user_name: fragment("? || ' ' || ?", u.first_name, u.last_name),
        user_email: u.email,
        user_role: u.role,
        complaint: c.complaint,
        status: c.status,
        admin_response: c.admin_response,
        inserted_at: c.inserted_at,
        updated_at: c.updated_at
      },
      order_by: [desc: c.inserted_at]
    
    Repo.all(query)
  end

  # Get complaints for one user
  def list_user_complaints_for_user(user_id) do
    Repo.all(from c in UserComplaint, where: c.user_id == ^user_id, order_by: [desc: c.inserted_at])
  end

  # Get a single complaint
  def get_user_complaint(id) do
    Repo.get(UserComplaint, id)
  end

  # Update complaint (for admin response)
  def update_user_complaint(%UserComplaint{} = complaint, attrs) do
    complaint
    |> UserComplaint.changeset(attrs)
    |> Repo.update()
  end

  # Delete a complaint
  def delete_user_complaint(%UserComplaint{} = complaint) do
    Repo.delete(complaint)
  end
end
