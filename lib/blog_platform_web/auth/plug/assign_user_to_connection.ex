defmodule BlogPlatformWeb.Auth.Plug.AssignUserToConnection do

  import Plug.Conn

  alias BlogPlatform.Users
  alias BlogPlatformWeb.Auth.ErrorResponse


  def init(_options) do

  end

  def call(conn, _options) do
    with {:ok, _user} <- Map.fetch(conn.assigns, :user) do
      conn
    else
      :error ->
        case get_session(conn, :user_id) do
          nil -> raise(ErrorResponse.Unauthorized)
          user_id ->
            user = Users.get_user!(user_id)
            assign(conn, :user, user)
        end
    end
  end
end
