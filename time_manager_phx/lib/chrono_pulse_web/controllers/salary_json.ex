defmodule ChronoPulseWeb.SalaryJSON do
  @doc """
  Renders a list of weekly salaries.
  """
  def weekly(%{salaries: salaries}) do
    %{data: Enum.map(salaries, &salary_data/1)}
  end

  @doc """
  Renders a single user's weekly salary.
  """
  def user_weekly(%{salary: salary}) do
    %{data: salary_data(salary)}
  end

  @doc """
  Renders overtime details.
  """
  def overtime_details(%{details: details}) do
    %{data: Enum.map(details, &overtime_detail_data/1)}
  end

  defp salary_data(salary) do
    %{
      user_id: salary.user_id,
      user_name: "#{salary.user.first_name} #{salary.user.last_name}",
      user_email: salary.user.email,
      user_role: salary.user.role,
      week_start: salary.week_start,
      week_end: salary.week_end,
      hourly_rate: salary.hourly_rate,
      base_hours: salary.base_hours,
      pending_overtime_hours: salary.pending_overtime_hours,
      approved_overtime_hours: salary.approved_overtime_hours,
      base_salary: salary.base_salary,
      overtime_pay: salary.overtime_pay,
      total_salary: salary.total_salary
    }
  end

  defp overtime_detail_data(detail) do
    %{
      id: detail.id,
      date: detail.date,
      start_time: detail.start_time,
      end_time: detail.end_time,
      scheduled_hours: detail.scheduled_hours,
      actual_hours: detail.actual_hours,
      overtime_hours: detail.overtime_hours,
      status: detail.status,
      approved_by: detail.approved_by
    }
  end
end

