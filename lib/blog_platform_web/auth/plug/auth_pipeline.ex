defmodule BlogPlatformWeb.Auth.Plug.AuthPipeline do

  use Guardian.Plug.Pipeline, otp_app: :blog_platform,
  module: BlogPlatformWeb.Auth.GuardianCore,
  error_handler: BlogPlatformWeb.Auth.Plug.GuardianErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource

end
