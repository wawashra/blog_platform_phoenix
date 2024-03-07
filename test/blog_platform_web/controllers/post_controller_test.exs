defmodule BlogPlatformWeb.PostControllerTest do
  use BlogPlatformWeb.ConnCase

  import BlogPlatform.PostsFixtures

  alias BlogPlatformWeb.Auth.GuardianCore

  describe "Test create a post for a normal user role" do
    setup :include_normal_user_token

    test "Auth the normal user by HTTP", %{conn: conn, user: user, password: password} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :login, email: user.email, password: password)
        )

      assert %{"token" => _token} = json_response(conn, 200)
      assert {:ok, _} = GuardianCore.decode_and_verify(json_response(conn, 200)["token"])
    end


    test "Add a post by a normal user to the same user", %{conn: conn, user: user, user2: _user2, token: token} do



      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)

      post_to_create = %{
        body: "some body",
        title: "some title",
        user_id: user.id
      }

      conn_results_for_post_ops = post(conn, Routes.post_path(conn, :create), post: post_to_create)

      assert %{"id" => id} = json_response(conn_results_for_post_ops, 201)["data"]

      conn_results_for_get_ops = get(conn, Routes.post_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "body" => "some body",
               "title" => "some title"
             } = json_response(conn_results_for_get_ops, 200)["data"]
    end

    test "Add a post by a normal user to another user", %{conn: conn, user: user, user2: user2, token: token} do
      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)
      post_to_create = %{
        body: "some body",
        title: "some title",
        user_id: user2.id
      }

      assert_error_sent 403, fn ->
        post(conn, Routes.post_path(conn, :create), post: post_to_create)
      end


    end

    test "Edit a post by a normal user to the same user", %{conn: conn, user: user, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)

      post = create_post(user.id)



      post_to_update = %{
        "body" => "some updated body",
        "title" => "some updated title"
      }

      conn_results_for_put_ops = put(conn, Routes.post_path(conn, :update, post.post), post: post_to_update)

      assert %{"id" => p_id} = json_response(conn_results_for_put_ops, 200)["data"]

      conn_results_for_get_ops = get(conn, Routes.post_path(conn, :show, p_id))

      assert %{
               "id" => ^p_id,
               "body" => "some updated body",
               "title" => "some updated title"
             } = json_response(conn_results_for_get_ops, 200)["data"]

    end

    test "Edit a post by a normal user to another user", %{conn: conn, user: user, user2: user2, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)

      post = create_post(user2.id)



      post_to_update = %{
        "body" => "some updated body",
        "title" => "some updated title"
      }


      assert_error_sent 403, fn ->
        put(conn, Routes.post_path(conn, :update, post.post), post: post_to_update)
      end
    end

    test "Delete a post by a normal user to the same user", %{conn: conn, user: user, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token)

      post = create_post(user.id)

      conn = delete(conn, Routes.post_path(conn, :delete, post.post))
      assert response(conn, 204)
    end

    test "Delete a post by a normal user to another user", %{conn: conn, user: user, user2: user2, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)

      post = create_post(user2.id)

      assert_error_sent 403, fn ->
        delete(conn, Routes.post_path(conn, :delete, post.post))
      end
    end
  end


  describe "Test create a post for an Admin user role" do
    setup :include_admin_token

    test "Auth the normal user by HTTP", %{conn: conn, user: user, password: password} do
      conn =
        post(
          conn,
          Routes.user_path(conn, :login, email: user.email, password: password)
        )

      assert %{"token" => _token} = json_response(conn, 200)
      assert {:ok, _} = GuardianCore.decode_and_verify(json_response(conn, 200)["token"])
    end

    test "Add a post by an Admin user to the same user", %{conn: conn, user: user, normal_user: _normal_user, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)

      post_to_create = %{
        body: "some body",
        title: "some title",
        user_id: user.id
      }

      conn_results_for_post_ops = post(conn, Routes.post_path(conn, :create), post: post_to_create)

      assert %{"id" => id} = json_response(conn_results_for_post_ops, 201)["data"]

      conn_results_for_get_ops = get(conn, Routes.post_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "body" => "some body",
               "title" => "some title"
             } = json_response(conn_results_for_get_ops, 200)["data"]
    end

    test "Add a post by an Admin user to another user", %{conn: conn, user: user, normal_user: normal_user, token: token} do
      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)
      post_to_create = %{
        body: "some body",
        title: "some title",
        user_id: normal_user.id
      }

      conn_results_for_post_ops = post(conn, Routes.post_path(conn, :create), post: post_to_create)

      assert %{"id" => id, "user_id"=> normal_user_id} = json_response(conn_results_for_post_ops, 201)["data"]

      conn_results_for_get_ops = get(conn, Routes.post_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "body" => "some body",
               "title" => "some title",
               "user_id"=> ^normal_user_id
               } = json_response(conn_results_for_get_ops, 200)["data"]

    end

    test "Edit a post by an Admin user to the same user", %{conn: conn, user: user, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)

      post = create_post(user.id)



      post_to_update = %{
        "body" => "some updated body",
        "title" => "some updated title"
      }

      conn_results_for_put_ops = put(conn, Routes.post_path(conn, :update, post.post), post: post_to_update)

      assert %{"id" => p_id} = json_response(conn_results_for_put_ops, 200)["data"]

      conn_results_for_get_ops = get(conn, Routes.post_path(conn, :show, p_id))

      assert %{
               "id" => ^p_id,
               "body" => "some updated body",
               "title" => "some updated title"
             } = json_response(conn_results_for_get_ops, 200)["data"]

    end

    test "Edit a post by an Admin user to another user", %{conn: conn, user: user, normal_user: normal_user, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)

      post = create_post(normal_user.id)



      post_to_update = %{
        "body" => "some updated body",
        "title" => "some updated title"
      }



      conn_results_for_put_ops = put(conn, Routes.post_path(conn, :update, post.post), post: post_to_update)

      assert %{"id" => p_id, "user_id"=> normal_user_id} = json_response(conn_results_for_put_ops, 200)["data"]

      conn_results_for_get_ops = get(conn, Routes.post_path(conn, :show, p_id))

      assert %{
               "id" => ^p_id,
               "body" => "some updated body",
               "title" => "some updated title",
               "user_id"=> ^normal_user_id
             } = json_response(conn_results_for_get_ops, 200)["data"]

    end

    test "Delete a post by an Admin user to the same user", %{conn: conn, user: user, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token)

      post = create_post(user.id)

      conn = delete(conn, Routes.post_path(conn, :delete, post.post))
      assert response(conn, 204)
    end

    test "Delete a post by an Admin user to another user", %{conn: conn, user: user, normal_user: normal_user, token: token} do

      conn = Plug.Conn.put_req_header(conn, "authorization", token) |> Plug.Conn.assign(:user, user)

      post = create_post(normal_user.id)

      conn = delete(conn, Routes.post_path(conn, :delete, post.post))
      assert response(conn, 204)

    end
  end

  defp create_post(user_id) do
    post = post_fixture(%{}, user_id)
    %{post: post}
  end
end
