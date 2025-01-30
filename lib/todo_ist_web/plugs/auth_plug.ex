defmodule TodoIstWeb.AuthPlug do
  use Guardian.Plug.Pipeline,
    otp_app: :todo_ist,
    error_handler: TodoIst.Authentication.ErrorHandler,
    module: TodoIst.Guardian,
    key: "el_auth_token"

  plug :fetch_cookies
  plug :fetch_session

  plug Guardian.Plug.VerifySession, refresh_from_cookie: true
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.LoadResource
  plug Guardian.Plug.EnsureAuthenticated
end
