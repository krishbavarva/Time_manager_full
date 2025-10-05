defmodule ChronoPulseWeb.SessionView do
  @moduledoc """
  This module handles the JSON rendering for session-related responses.
  """

  def render("token.json", %{token: token}) do
    %{
      data: %{
        token: token,
        type: "bearer"
      }
    }
  end
end
