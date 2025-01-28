defmodule TodoIstWeb.RouteHandlers.UserRouter do
  use TodoIstWeb, :router

  scope "/", TodoIstWeb do
    get "/get-user", UserController, :get_user
  end
end
