defmodule BlogPlatformWeb.Plug.AuthorizedPost do
  alias BlogPlatform.Posts
  alias BlogPlatform.Users.User
  alias BlogPlatformWeb.Auth.ErrorResponse

  @user_type :USER
  @admin_type :ADMIN

  def is_authorized_to_edit(
        %{
          path_params: %{"id" => id},
          params: %{"post" => new_post},
          assigns: %{user: %User{} = assign_user}
        } = conn,
        _opts
      ) do
    post = Posts.get_post!(id)

    case Map.fetch(new_post, "user_id") do
      {:ok, user_id} ->
        cond do
          (assign_user.id == user_id and
             (assign_user.role == @user_type or assign_user.role == @admin_type)) or
              (assign_user.id != user_id and assign_user.role == @admin_type) ->
            conn

          assign_user.id != user_id and assign_user.role == @user_type ->
            raise ErrorResponse.Forbidden
        end

      :error ->
        cond do
          assign_user.id != post.user_id and assign_user.role == @user_type ->
            raise ErrorResponse.Forbidden

          assign_user.id == post.user_id || assign_user.role == @admin_type ->
            conn
        end
    end
  end

  def is_authorized_to_delete(%{path_params: %{"id" => id}, assigns: %{user: %User{} = assign_user}} = conn, _opts) do
    post = Posts.get_post!(id)

    cond do
      assign_user.id != post.user_id and assign_user.role == @user_type ->
        raise ErrorResponse.Forbidden

        assign_user.id == post.user_id || assign_user.role == @admin_type ->
        conn
    end
  end

  def is_authorized_to_add(
        %{params: %{"post" => post}, assigns: %{user: %User{} = assign_user}} = conn,
        _opts
      ) do
    case Map.fetch(post, "user_id") do
      {:ok, user_id} ->
        cond do
          (assign_user.id == user_id and
             (assign_user.role == @user_type or assign_user.role == @admin_type)) or
              (assign_user.id != user_id and assign_user.role == @admin_type) ->
            conn

          assign_user.id != user_id and assign_user.role == @user_type ->
            raise ErrorResponse.Forbidden
        end
    end
  end

end
