defmodule ChronoPulse.Salary do
  @moduledoc """
  The Salary context for calculating and managing employee salaries.
  """
  import Ecto.Query, warn: false
  alias ChronoPulse.Repo
  alias ChronoPulse.TimeTracking.WorkingTime
  alias ChronoPulse.Accounts.User

  @doc """
  Calculate weekly salary for a user.
  Returns salary breakdown including base pay and overtime pay.
  """
  def calculate_weekly_salary(user_id, week_start_date) do
    week_end_date = Date.add(week_start_date, 6)
    
    # Get user with hourly rate
    user = Repo.get!(User, user_id)
    hourly_rate = user.hourly_rate || 15.0
    
    # Get all working times for the week
    query = from wt in WorkingTime,
      where: wt.user_id == ^user_id,
      where: fragment("date(?)", wt.start) >= ^week_start_date,
      where: fragment("date(?)", wt.start) <= ^week_end_date,
      select: wt
    
    working_times = Repo.all(query)
    
    # Calculate totals
    total_actual_hours = Enum.reduce(working_times, 0.0, fn wt, acc -> 
      acc + (wt.actual_hours || 0.0) 
    end)
    
    total_scheduled_hours = Enum.reduce(working_times, 0.0, fn wt, acc -> 
      acc + (wt.scheduled_hours || 0.0) 
    end)
    
    # Separate pending and approved overtime
    pending_overtime = Enum.reduce(working_times, 0.0, fn wt, acc ->
      if wt.status == "pending" do
        acc + (wt.overtime_hours || 0.0)
      else
        acc
      end
    end)
    
    approved_overtime = Enum.reduce(working_times, 0.0, fn wt, acc ->
      if wt.status == "approved" do
        acc + (wt.overtime_hours || 0.0)
      else
        acc
      end
    end)
    
    # Calculate salary
    base_hours = total_actual_hours - (pending_overtime + approved_overtime)
    base_salary = base_hours * hourly_rate
    overtime_pay = approved_overtime * hourly_rate * 2  # Double rate for overtime
    total_salary = base_salary + overtime_pay
    
    %{
      user_id: user_id,
      user: user,
      week_start: week_start_date,
      week_end: week_end_date,
      hourly_rate: hourly_rate,
      base_hours: Float.round(base_hours, 2),
      pending_overtime_hours: Float.round(pending_overtime, 2),
      approved_overtime_hours: Float.round(approved_overtime, 2),
      base_salary: Float.round(base_salary, 2),
      overtime_pay: Float.round(overtime_pay, 2),
      total_salary: Float.round(total_salary, 2),
      working_times: working_times
    }
  end

  @doc """
  Get weekly salary data for all employees and managers (exclude admins).
  """
  def list_weekly_salaries(week_start_date) do
    query = from u in User,
      where: u.role in ["employee", "manager"],
      select: u
    
    users = Repo.all(query)
    
    Enum.map(users, fn user ->
      calculate_weekly_salary(user.id, week_start_date)
    end)
  end

  @doc """
  Get detailed overtime breakdown for a user for a specific week.
  Groups by day and shows which days had overtime.
  """
  def get_overtime_details(user_id, week_start_date) do
    week_end_date = Date.add(week_start_date, 6)
    
    query = from wt in WorkingTime,
      where: wt.user_id == ^user_id,
      where: fragment("date(?)", wt.start) >= ^week_start_date,
      where: fragment("date(?)", wt.start) <= ^week_end_date,
      where: wt.overtime_hours > ^0.0,
      select: wt,
      order_by: [asc: wt.start]
    
    working_times = Repo.all(query)
    
    # Group by date
    Enum.map(working_times, fn wt ->
      date = DateTime.to_date(wt.start)
      %{
        id: wt.id,
        date: date,
        start_time: wt.start,
        end_time: wt.end,
        scheduled_hours: wt.scheduled_hours || 0.0,
        actual_hours: wt.actual_hours || 0.0,
        overtime_hours: wt.overtime_hours || 0.0,
        status: wt.status || "pending",
        approved_by: wt.approved_by
      }
    end)
  end

  @doc """
  Approve overtime for a working time entry.
  """
  def approve_overtime(working_time_id, admin_id) do
    working_time = Repo.get!(WorkingTime, working_time_id)
    
    working_time
    |> WorkingTime.changeset(%{status: "approved", approved_by: admin_id})
    |> Repo.update()
  end

  @doc """
  Reject overtime for a working time entry.
  """
  def reject_overtime(working_time_id, admin_id) do
    working_time = Repo.get!(WorkingTime, working_time_id)
    
    working_time
    |> WorkingTime.changeset(%{status: "rejected", approved_by: admin_id})
    |> Repo.update()
  end
end

