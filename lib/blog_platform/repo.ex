defmodule BlogPlatform.Repo do
  use Ecto.Repo,
    otp_app: :blog_platform,
    adapter: Ecto.Adapters.MyXQL
end
