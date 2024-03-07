defmodule BlogPlatformWeb.Auth.Plug.AssignUserToConnection do

  import Plug.Conn

  alias BlogPlatform.Users
  alias BlogPlatformWeb.Auth.ErrorResponse


  def init(_options) do

  end

  def call(conn, _options) do

    case Guardian.Plug.current_resource(conn) do
      nil -> raise(ErrorResponse.Unauthorized)
      current_user ->
        user = Users.get_user!(current_user.id)
        assign(conn, :user, user)
    end

  end
end
