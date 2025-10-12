defmodule ChronoPulseWeb.Router do
  use ChronoPulseWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug ChronoPulseWeb.Plugs.Auth
  end

  scope "/api", ChronoPulseWeb do
    pipe_through :api
    
    # Authentication routes
    post "/sessions", SessionController, :create
    
    # User routes
    resources "/users", UserController, except: [:new, :edit]
    
    # WorkingTime routes per PDF
    get "/workingtime/:user_id", WorkingTimeController, :index
    get "/workingtime/:user_id/:id", WorkingTimeController, :show
    post "/workingtime/:user_id", WorkingTimeController, :create
    put "/workingtime/:id", WorkingTimeController, :update
    delete "/workingtime/:id", WorkingTimeController, :delete
    
    # Clocks as per PDF
    get "/clocks/:user_id", ClockController, :index
    post "/clocks/:user_id", ClockController, :create
    
    # Charts
    get "/charts/hours", ChartsController, :total_hours
    get "/charts/user/:user_id/hours", ChartsController, :user_hours
    get "/charts/user/:user_id/sessions", ChartsController, :user_sessions
    get "/charts/user/:user_id/breaks", ChartsController, :user_breaks
    
    # Time Management Features
    resources "/attendance", AttendanceController, except: [:new, :edit]
    resources "/leave_requests", LeaveRequestController, except: [:new, :edit]
    get "/leave_requests/user/:user_id", LeaveRequestController, :user_requests
    post "/leave_requests/:id/approve", LeaveRequestController, :approve
    post "/leave_requests/:id/reject", LeaveRequestController, :reject
    resources "/overtime_requests", OvertimeRequestController, except: [:new, :edit]
    
    # User schedules
    resources "/user_schedules", UserScheduleController, except: [:new, :edit]
    get "/user_schedules/user/:user_id", UserScheduleController, :by_user
    
    # Break calculation
    get "/breaks/user/:user_id/date/:date", BreakController, :calculate
    
    # Team clock-in
    post "/teams/:team_id/clock_in", TeamClockController, :clock_in_team
    
    # Timesheet approval
    resources "/timesheet_approvals", TimesheetApprovalController, except: [:new, :edit]
    post "/timesheet_approvals/:id/approve", TimesheetApprovalController, :approve
    post "/timesheet_approvals/:id/reject", TimesheetApprovalController, :reject
    
    # Salary routes
    get "/salaries/weekly", SalaryController, :weekly
    get "/salaries/user/:user_id/weekly", SalaryController, :user_weekly
    get "/salaries/overtime/:user_id", SalaryController, :overtime_details
    post "/salaries/overtime/:id/approve", SalaryController, :approve_overtime
    post "/salaries/overtime/:id/reject", SalaryController, :reject_overtime
    
    # Complaints routes
    get "/complaints", UserComplaintController, :index
    get "/complaints/user/:user_id", UserComplaintController, :user_complaints
    post "/complaints", UserComplaintController, :create
    put "/complaints/:id", UserComplaintController, :update
    delete "/complaints/:id", UserComplaintController, :delete
    
    # Other routes
    post "/chat", ChatController, :create
    resources "/teams", TeamController, except: [:new, :edit]
    get "/managers/:manager_id/teams", TeamController, :by_manager
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:chrono_pulse, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
