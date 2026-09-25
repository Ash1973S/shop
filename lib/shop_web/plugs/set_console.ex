defmodule ShopWeb.Plugs.SetConsole do
  import Plug.Conn
  def init(default_console), do: default_console

  @valid_consoles ["pc", "xbox", "ps", "nitendo"]

  @doc """
  Plug pattern-matching function

  Extracts a console parameter from the request
  Assigns it to the connection under the key :console, which
  makes it available to views from the downstream via conn.assigns.console
  """
  def call(%Plug.Conn{:params => %{"console" => console}} = conn, _default_console)
      when console in @valid_consoles do
    conn
    |> assign(:console, console)
    |> put_resp_cookie("console", console, max_age: :timer.hours(24) * 30)
  end

  # read cookie value
  def call(%Plug.Conn{:cookies => %{"console" => console}} = conn, _default_console)
      when console in @valid_consoles do
    conn
    |> assign(:console, console)
  end

  # if no console variable is available
  def call(%Plug.Conn{} = conn, default_console) do
    conn |> assign(:console, default_console)
  end
end
