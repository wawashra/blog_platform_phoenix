defmodule BlogPlatformWeb.UserView do
  use BlogPlatformWeb, :view
  alias BlogPlatformWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      user_name: user.user_name,
      email: user.email,
      password: user.password_hash
    }
  end

  def render("user_token.json", %{user: user, token: token}) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      user_name: user.user_name,
      email: user.email,
      token: token
    }
  end

end
