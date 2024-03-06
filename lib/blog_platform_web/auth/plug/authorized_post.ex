defmodule BlogPlatformWeb.Plug.AuthorizedPost do

  alias BlogPlatform.Posts
  alias BlogPlatformWeb.Auth.ErrorResponse

  @user_type :USER
  @admin_type :ADMIN
  def is_authorized(%{path_params: %{"id" => id}, params: %{"post" => new_post}} = conn, _opts) do
    post = Posts.get_post!(id)
    current_user = conn.assigns.user


    IO.inspect("current_user>>>>>>>>>>>>>>")
    IO.inspect(current_user)
    IO.inspect(new_post)
    IO.inspect(post.user_id)
    IO.inspect(Map.has_key?(new_post, "user_id"))
    IO.inspect("<<<<<<<<<<<<<<<<current_user")

    if (current_user.id == post.user_id) || (current_user.role == @admin_type) do

      new_post_has_user_id = Map.has_key?(new_post, "user_id")
      old_post_user_id = post.user_id
      current_user_role = current_user.role


      if(new_post_has_user_id and Map.fetch!(new_post, "user_id") !== old_post_user_id and current_user_role === @user_type) do
        # IO.inspect("I'm here ! ")
        # IO.inspect(new_post)
        raise ErrorResponse.Forbidden
      else
        conn
      end

    else
      raise ErrorResponse.Forbidden
    end
  end

  def is_authorized_to_delete(%{path_params: %{"id" => id}} = conn, _opts) do
    post = Posts.get_post!(id)
    current_user = conn.assigns.user


    IO.inspect("current_user>>>>>>>>>>>>>>")
    IO.inspect(current_user)
    IO.inspect(post.user_id)
    IO.inspect("<<<<<<<<<<<<<<<<current_user")

    if (current_user.id == post.user_id) || (current_user.role == @admin_type) do

      conn
    else
      raise ErrorResponse.Forbidden
    end
  end
  def is_authorized_to_add(%{params: %{"post" => post}} = conn, _opts) do
    current_user = conn.assigns.user

    IO.inspect(conn)
    IO.inspect(current_user)
    IO.inspect(Map.has_key?(post, "user_id"))

    if (Map.has_key?(post, "user_id") and current_user.id == Map.fetch!(post, "user_id")) || (current_user.role == @admin_type) do
      conn
    else
      raise ErrorResponse.Forbidden
    end
  end


end
