defmodule BlogPlatformWeb.PostController do
  use BlogPlatformWeb, :controller

  alias BlogPlatform.Posts
  alias BlogPlatform.Posts.Post

  import BlogPlatformWeb.Plug.AuthorizedPost

  plug :is_authorized_to_edit when action in [:update]

  plug :is_authorized_to_add when action in [:create]
  plug :is_authorized_to_delete when action in [:delete]



  plug Hammer.Plug, [
    rate_limit: {"act_with_apis", 60_000, 5},
    by: {:session, :ip}
  ] when action in [:index, :create, :show, :delete]

  action_fallback BlogPlatformWeb.FallbackController

  def index(conn, _params) do
    posts = Posts.list_posts()
    render(conn, "index.json", posts: posts)
  end

  def create(conn, %{"post" => post_params}) do

    post_to_create = %{post_params | "user_id" => Map.get(post_params, "user_id", conn.assigns.user.id)}

    with {:ok, %Post{} = post} <- Posts.create_post(post_to_create) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.post_path(conn, :show, post))
      |> render("show.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    render(conn, "show.json", post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    with {:ok, %Post{} = post} <- Posts.update_post(post, post_params) do
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)

    with {:ok, %Post{}} <- Posts.delete_post(post) do
      send_resp(conn, :no_content, "")
    end
  end
end
