defmodule ShopWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use ShopWeb, :controller
      use ShopWeb, :html

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
      import Phoenix.LiveView.Router
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

      use Gettext, backend: ShopWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  # This is a private macro definition in your ShopWeb module
  # (typically lib/shop_web.ex) that bundles together all the common imports,
  # aliases, and macros needed by every HTML template or LiveView render function.
  defp html_helpers do
    quote do
      # Enables the gettext/1, dgettext/3, and ngettext/4 macros for internationalization
      use Gettext, backend: ShopWeb.Gettext

      # Brings in core HTML helpers like tag/2, link/2, form_for/3, and most importantly
      # the safe rendering pipeline that auto-escapes interpolated values to prevent XSS
      import Phoenix.HTML

      # Makes all your shared UI components (<.button>, <.input>, <.flash_group>, etc.)
      # available directly in templates without needing ShopWeb.CoreComponents.button(...) syntax.
      import ShopWeb.CoreComponents

      # Lets you write JS.push("event"), JS.toggle(), etc. in templates and assigns instead of
      # the fully qualified Phoenix.LiveView.JS.push(...)
      alias Phoenix.LiveView.JS

      # Shortens references to your layout functions so you can call Layouts.root(...) instead of
      # ShopWeb.Layouts.root(...).
      alias ShopWeb.Layouts

      # Injects the ~p sigil and route helper functions from the verified_routes/0 macro
      # enabling compile-time-checked paths like ~p"/users/#{@id}".
      unquote(verified_routes())
    end
  end

  @doc """
  Verified Routes is a Phoenix feature (introduced in v1.7) that turns route helpers
  into compile-time checked functions.

  Instead of passing string paths like "/pages/about" and hoping they exist,
  you get named functions that fail to compile if the route doesn't exist.
  """
  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ShopWeb.Endpoint,
        router: ShopWeb.Router,
        statics: ShopWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
