defmodule BlogPlatformWeb.UserControllerTest do
  use BlogPlatformWeb.ConnCase

  alias BlogPlatformWeb.Auth.GuardianCore


  @create_attrs %{
    first_name: "Waseem",
    last_name: "Waseem",
    email: "wawashra+eeeeeee@gmail.com",
    user_name: "wawashra+eeeee",
    password: "123456",
    password_confirmation: "123456"
  }

  @invalid_attrs %{email: nil, name: nil, username: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create normal user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :new), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)
      assert %{"token" => _token} = json_response(conn, 201)
      assert {:ok, _} = GuardianCore.decode_and_verify(json_response(conn, 201)["token"])

      conn = get(conn, Routes.user_path(conn, :show, id))


      assert %{
               "id" => ^id,
               "email" => "wawashra+eeeeeee@gmail.com",
               "first_name" => "Waseem",
               "last_name" => "Waseem",
               "user_name" => "wawashra+eeeee"
             } = json_response(conn, 200)["data"]

      refute json_response(conn, 200)["data"]["password"] === @create_attrs["password"]
    end

    test "renders 422 when data are already been taken", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :new), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "email" => "wawashra+eeeeeee@gmail.com",
               "first_name" => "Waseem",
               "last_name" => "Waseem",
               "user_name" => "wawashra+eeeee"
             } = json_response(conn, 200)["data"]

      refute json_response(conn, 200)["data"]["password"] === @create_attrs["password"]


      conn = post(conn, Routes.user_path(conn, :new), user: @create_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end


    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

end
