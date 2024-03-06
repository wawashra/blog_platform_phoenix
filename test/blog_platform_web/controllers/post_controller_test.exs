defmodule BlogPlatformWeb.PostControllerTest do
  use BlogPlatformWeb.ConnCase

  import BlogPlatform.PostsFixtures

  alias BlogPlatform.Posts.Post
  alias BlogPlatformWeb.Auth.GuardianCore

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  describe "post for normal user" do
    setup :include_normal_user_token

    test "create token", %{conn: conn, user: user, password: password} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :login, email: user.email, password: password)
        )

      assert %{"token" => _token} = json_response(conn, 200)
      assert {:ok, _} = GuardianCore.decode_and_verify(json_response(conn, 200)["token"])
    end


    test "add post when data is valid", %{conn: conn, user: user, token: token} do
      conn = Plug.Conn.put_req_header(conn, "authorization", token)

      post_to_create = %{
        body: "some body",
        title: "some title",
        user_id: user.id
      }

      conn = post(conn, Routes.post_path(conn, :create), post: post_to_create)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.post_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "body" => "some body",
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "add post when data is invalid", %{conn: conn, user: user, user2: user2, token: token} do
      conn = Plug.Conn.put_req_header(conn, "authorization", token)

      post_to_create = %{
        body: "some body",
        title: "some title",
        user_id: user2.id
      }

      assert_error_sent 403, fn ->
        conn = post(conn, Routes.post_path(conn, :create), post: post_to_create)
      end


    end

    test "update post when data is valid", %{conn: conn, user: user, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token)

      post = create_post(user.id)



      post_to_update = %{
        "body" => "some updated body",
        "title" => "some updated title"
      }

      conn = put(conn, Routes.post_path(conn, :update, post.post), post: post_to_update)
      assert %{"id" => p_id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.post_path(conn, :show, p_id))

      assert %{
               "id" => ^p_id,
               "body" => "some updated body",
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]

    end

    test "delete post when data is valid", %{conn: conn, user: user, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token)

      post = create_post(user.id)

      conn = delete(conn, Routes.post_path(conn, :delete, post.post))
      assert response(conn, 204)
    end

    test "delete post when data is invalid", %{conn: conn, user: user, user2: user2, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token)

      post = create_post(user2.id)

      assert_error_sent 403, fn ->
        conn = delete(conn, Routes.post_path(conn, :delete, post.post))
      end
    end
  end

  defp create_post(user_id) do
    post = post_fixture(%{}, user_id)
    %{post: post}
  end
end
