defmodule BlogPlatformWeb.PostView do
  use BlogPlatformWeb, :view
  alias BlogPlatformWeb.PostView

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{
      id: post.id,
      user_id: post.user_id,
      title: post.title,
      body: post.body
    }
  end
end
