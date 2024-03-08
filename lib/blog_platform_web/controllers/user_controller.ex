defmodule BlogPlatformWeb.UserController do
  alias BlogPlatformWeb.Auth.GuardianCore
  use BlogPlatformWeb, :controller

  alias BlogPlatform.Users
  alias BlogPlatform.Users.User

  plug Hammer.Plug, [
    rate_limit: {"act_with_apis", 60_000, 5},
    by: {:session, :ip}
  ] when action in [:index, :create, :show, :delete]

  action_fallback BlogPlatformWeb.FallbackController

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.json", users: users)
  end


  def new(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params),
          {:ok, token, _claims} <- GuardianCore.encode_and_sign(user) do
      conn
      |> put_status(:created)
      |> render("user_token.json", %{user: user, token: token})
    end
  end


  def login(conn, %{"email" => email, "password" => password}) do
    case GuardianCore.authenticate(email, password) do
      {:ok, user, token} ->
        conn
        |> Plug.Conn.put_session(:user_id, user.id)
        |> put_status(:ok)
        |> render("user_token.json", %{user: user, token: token})
      {:error, :unauthorized} ->
        raise BlogPlatformWeb.Auth.ErrorResponse.Unauthorized, message: "Email Or Password incorrect"
    end
  end


  def logout(conn, %{}) do
    user = conn.assigns[:user]

    token = Guardian.Plug.current_token(conn)
    GuardianCore.revoke(token)

    conn
    |> Plug.Conn.clear_session()
    |> put_status(:ok)
    |> render("user_token.json", %{user: user, token: token})
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    with {:ok, %User{}} <- Users.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
