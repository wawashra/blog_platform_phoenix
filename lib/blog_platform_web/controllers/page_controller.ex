defmodule BlogPlatformWeb.PageController do
  use BlogPlatformWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
