defmodule BlogPlatform.UsersFixtures do
  alias BlogPlatform.Users

  def user_attrs(attrs \\ %{}) do
    valid_attrs = %{
      first_name: "blog first_name",
      last_name: "blog last_name",
      user_name: "blog user_name#{:rand.uniform(10_000)}",
      password: "blog_password",
      password_confirmation: "blog_password",
      email: "blog@email#{:rand.uniform(10_000)}",
    }

    Enum.into(attrs, valid_attrs)
  end

  def admin_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> user_attrs()
      |> Map.put(:role, "ADMIN")
      |> Users.create_user()

    user
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> user_attrs()
      |> Users.create_user()

    user
  end
end
