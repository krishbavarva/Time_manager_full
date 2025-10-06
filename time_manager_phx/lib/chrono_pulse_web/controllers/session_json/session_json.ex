defmodule ChronoPulseWeb.SessionJSON do
  def token(%{token: token}) do
    %{
      data: %{
        token: token,
        type: "bearer"
      }
    }
  end
end
