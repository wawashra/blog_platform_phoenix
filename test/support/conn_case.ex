defmodule BlogPlatformWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use BlogPlatformWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate
  alias BlogPlatformWeb.Auth.GuardianCore

  import BlogPlatform.UsersFixtures

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import BlogPlatformWeb.ConnCase

      alias BlogPlatformWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint BlogPlatformWeb.Endpoint
    end
  end

  setup tags do
    BlogPlatform.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def include_normal_user_token(%{conn: conn}) do
    user = user_fixture()
    user2 = user_fixture()

    password = "blog_password"
    {:ok, _, token} = GuardianCore.authenticate(user.email, password)
    conn = Plug.Conn.put_req_header(conn, "authorization", token)
    conn = Plug.Conn.assign(conn, :user, user)

    {:ok, conn: conn, user: user, user2: user2, password: password, token: "Bearer " <> token}
  end



  def include_admin_token(%{conn: conn}) do
    user = admin_fixture()
    password = "blog_password"
    {:ok, _, token} = GuardianCore.authenticate(user.email, password)
    conn = Plug.Conn.put_req_header(conn, "authorization", "Bearer " <> token)
    conn = Plug.Conn.assign(conn, :user, user)
    {:ok, conn: conn, user: user, password: password, token: "Bearer " <> token}
  end

end
