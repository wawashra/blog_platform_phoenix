defmodule BlogPlatformWeb.Auth.ErrorResponse.Unauthorized do
  defexception [message: "Unauthorized", plug_status: 401]
end


defmodule BlogPlatformWeb.Auth.ErrorResponse.Forbidden do
  defexception [message: "You do not have access to this resource.", plug_status: 403]
end

defmodule BlogPlatformWeb.Auth.ErrorResponse.InvalidToken do
  defexception [message: "invalid_token.", plug_status: 401]
end
