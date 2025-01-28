defmodule TodoIstWeb.Authentication do
  # import Plug.Conn
  use Guardian.Plug.Pipeline,
    otp_app: :auth_me,
    error_handler: AuthMe.UserManager.ErrorHandler,
    module: AuthMe.UserManager.Guardian

  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.LoadResource, allow_blank: true
end
