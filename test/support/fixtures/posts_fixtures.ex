defmodule BlogPlatform.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BlogPlatform.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}, user_id) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        title: "some title",
        user_id: user_id
      })
      |> BlogPlatform.Posts.create_post()

    post
  end
end
