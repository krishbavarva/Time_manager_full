defmodule ChronoPulseWeb.UserComplaintController do
  use ChronoPulseWeb, :controller

  alias ChronoPulse.UserComplaints

  # List all complaints (admin)
  def index(conn, _params) do
    complaints = UserComplaints.list_user_complaints()
    json(conn, %{data: complaints})
  end

  # List complaints for a specific user
  def user_complaints(conn, %{"user_id" => user_id}) do
    complaints = UserComplaints.list_user_complaints_for_user(user_id)
    json(conn, %{data: complaints})
  end

  # Create a new complaint
  def create(conn, %{"user_id" => user_id, "complaint" => complaint}) do
    case UserComplaints.create_user_complaint(%{user_id: user_id, complaint: complaint}) do
      {:ok, user_complaint} ->
        json(conn, %{status: "success", data: user_complaint})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: translate_errors(changeset)})
    end
  end

  # Update a complaint (admin response)
  def update(conn, %{"id" => id, "status" => status, "admin_response" => admin_response}) do
    case UserComplaints.get_user_complaint(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Complaint not found"})

      complaint ->
        case UserComplaints.update_user_complaint(complaint, %{status: status, admin_response: admin_response}) do
          {:ok, updated_complaint} ->
            json(conn, %{status: "success", data: updated_complaint})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", errors: translate_errors(changeset)})
        end
    end
  end

  # Update a complaint (status only)
  def update(conn, %{"id" => id, "status" => status}) do
    case UserComplaints.get_user_complaint(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Complaint not found"})

      complaint ->
        case UserComplaints.update_user_complaint(complaint, %{status: status}) do
          {:ok, updated_complaint} ->
            json(conn, %{status: "success", data: updated_complaint})

          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{status: "error", errors: translate_errors(changeset)})
        end
    end
  end

  # Delete a complaint
  def delete(conn, %{"id" => id}) do
    case UserComplaints.get_user_complaint(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{status: "error", message: "Complaint not found"})

      complaint ->
        case UserComplaints.delete_user_complaint(complaint) do
          {:ok, _} ->
            json(conn, %{status: "success", message: "Complaint deleted"})

          {:error, _} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{status: "error", message: "Failed to delete complaint"})
        end
    end
  end

  # helper function to make errors JSON-encodable
  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
