defmodule ChronoPulseWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use ChronoPulseWeb, :controller
      use ChronoPulseWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]

      use Gettext, backend: ChronoPulseWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/chrono_pulse_web/templates",
        namespace: ChronoPulseWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  defp view_helpers do
    quote do
      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import ChronoPulseWeb.ErrorHelpers
      import ChronoPulseWeb.Gettext
      alias ChronoPulseWeb.Router.Helpers, as: Routes
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ChronoPulseWeb.Endpoint,
        router: ChronoPulseWeb.Router,
        statics: ChronoPulseWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
