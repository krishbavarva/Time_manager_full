defmodule ChronoPulseWeb.SalaryController do
  use ChronoPulseWeb, :controller
  alias ChronoPulse.Salary

  action_fallback ChronoPulseWeb.FallbackController

  @doc """
  GET /api/salaries/weekly
  Get weekly salaries for all employees/managers
  Params: week_start (date string, e.g., "2025-10-07")
  """
  def weekly(conn, params) do
    week_start = case params["week_start"] do
      nil -> Date.beginning_of_week(Date.utc_today(), :monday)
      date_string -> Date.from_iso8601!(date_string)
    end
    
    salaries = Salary.list_weekly_salaries(week_start)
    render(conn, :weekly, salaries: salaries)
  end

  @doc """
  GET /api/salaries/user/:user_id/weekly
  Get weekly salary for a specific user
  Params: week_start (optional)
  """
  def user_weekly(conn, %{"user_id" => user_id} = params) do
    week_start = case params["week_start"] do
      nil -> Date.beginning_of_week(Date.utc_today(), :monday)
      date_string -> Date.from_iso8601!(date_string)
    end
    
    salary = Salary.calculate_weekly_salary(user_id, week_start)
    render(conn, :user_weekly, salary: salary)
  end

  @doc """
  GET /api/salaries/overtime/:user_id
  Get overtime details for a user for a specific week
  Params: week_start (optional)
  """
  def overtime_details(conn, %{"user_id" => user_id} = params) do
    week_start = case params["week_start"] do
      nil -> Date.beginning_of_week(Date.utc_today(), :monday)
      date_string -> Date.from_iso8601!(date_string)
    end
    
    details = Salary.get_overtime_details(user_id, week_start)
    render(conn, :overtime_details, details: details)
  end

  @doc """
  POST /api/salaries/overtime/:id/approve
  Approve overtime for a working time entry
  """
  def approve_overtime(conn, %{"id" => working_time_id}) do
    # Get current admin user from auth plug
    admin_id = conn.assigns[:current_user][:id]
    
    case Salary.approve_overtime(working_time_id, admin_id) do
      {:ok, working_time} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "Overtime approved successfully"})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end

  @doc """
  POST /api/salaries/overtime/:id/reject
  Reject overtime for a working time entry
  """
  def reject_overtime(conn, %{"id" => working_time_id}) do
    # Get current admin user from auth plug
    admin_id = conn.assigns[:current_user][:id]
    
    case Salary.reject_overtime(working_time_id, admin_id) do
      {:ok, working_time} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "Overtime rejected successfully"})
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: changeset})
    end
  end
end

