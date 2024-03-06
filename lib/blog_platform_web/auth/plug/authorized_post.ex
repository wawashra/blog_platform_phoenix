defmodule BlogPlatformWeb.Plug.AuthorizedPost do
  alias BlogPlatform.Posts
  alias BlogPlatformWeb.Auth.ErrorResponse

  @user_type :USER
  @admin_type :ADMIN

  def is_authorized_to_edit(%{path_params: %{"id" => id}, params: %{"post" => new_post}} = conn, _opts) do
    post = Posts.get_post!(id)

    case Map.fetch(new_post, "user_id") do
      {:ok, user_id} ->
        cond do
          (conn.assigns.user.id == user_id and conn.assigns.user.role == @user_type)
          or
          (conn.assigns.user.id != user_id and conn.assigns.user.role == @admin_type) ->
            conn

          conn.assigns.user.id != user_id and conn.assigns.user.role == @user_type ->
            raise ErrorResponse.Forbidden
        end
      :error ->
        cond do
          conn.assigns.user.id != post.user_id and conn.assigns.user.role == @user_type ->
            raise ErrorResponse.Forbidden

            conn.assigns.user.id == post.user_id || conn.assigns.user.role == @admin_type ->
            conn
        end
    end
  end

  def is_authorized_to_delete(%{path_params: %{"id" => id}} = conn, _opts) do
    post = Posts.get_post!(id)
    current_user = conn.assigns.user
    cond do
      current_user.id != post.user_id and conn.assigns.user.role == @user_type ->
        raise ErrorResponse.Forbidden

      current_user.id == post.user_id || current_user.role == @admin_type ->
        conn
    end
  end

  def is_authorized_to_add(%{params: %{"post" => post}} = conn, _opts) do
    case Map.fetch(post, "user_id") do
      {:ok, user_id} ->
        cond do
          (conn.assigns.user.id == user_id and conn.assigns.user.role == @user_type)
          or
          (conn.assigns.user.id != user_id and conn.assigns.user.role == @admin_type) ->
            conn

          conn.assigns.user.id != user_id and conn.assigns.user.role == @user_type ->
            raise ErrorResponse.Forbidden
        end
    end
  end
end
