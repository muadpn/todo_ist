defmodule TodoIstWeb.RouteHandlers.MessageRouter do
  use TodoIstWeb, :router

  scope "/", TodoIstWeb do
    get "/get-user-messages", Message.MessageQueryController, :get_user_message
  end
end
