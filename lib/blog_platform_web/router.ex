defmodule BlogPlatformWeb.Router do
  use BlogPlatformWeb, :router
  use Plug.ErrorHandler

  def handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end

  def handle_errors(conn, %{reason: %{message: message}}) do
    conn |> json(%{errors: message}) |> halt()
  end


  def handle_errors(conn, _) do
    conn |> json(%{errors: "Nothing Know "}) |> halt()
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BlogPlatformWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
  end

  pipeline :auth do
    plug BlogPlatformWeb.Auth.Plug.AuthPipeline
  end

  scope "/", BlogPlatformWeb do
    pipe_through :browser

    get "/", PageController, :index
  end


  scope "/api", BlogPlatformWeb do
    pipe_through [:api, :auth]
    # resources "/posts", PostController, except: [:new, :edit]
    post "/posts", PostController, :create

    get "/posts", PostController, :index
    get "/posts/:id", PostController, :show

    get "/users/logout", UserController, :logout
    get "/users/refresh", UserController, :refresh_token

    put "/posts/:id", PostController, :update
    patch "/posts/:id", PostController, :update
    delete "/posts/:id", PostController, :delete

  end

  scope "/api", BlogPlatformWeb do
    pipe_through :api

    post "/users/register", UserController, :new
    post "/users/login", UserController, :login

    resources "/users", UserController, except: [:new, :edit]

  end
  # Other scopes may use custom stacks.
  # scope "/api", BlogPlatformWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BlogPlatformWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
