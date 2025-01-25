defmodule TodoIstWeb.AuthRouter do
  use TodoIstWeb, :router

  scope "/", TodoIstWeb do
    post "/login", LoginController, :login
    post "sign-up", LoginController, :signup
  end
end
