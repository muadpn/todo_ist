defmodule TodoIstWeb.RouteHandlers.UserRouter do
  use TodoIstWeb, :router
  # alias TodoIstWeb.User.UsersQueryController
  alias User.{UsersQueryController, UsersMutationController}

  scope "/", TodoIstWeb do
    get "/get-user", UserController, :get_user
    get "/email", UsersQueryController, :users_by_email_query
    post "/send-friend-request", UsersMutationController, :send_friend_request
    get "/pending-friend-request", UsersQueryController, :fetch_pending_request
    get "/friends", UsersQueryController, :fetch_friends
    post "/accept-friend-request", UsersMutationController, :accept_friend_request
  end

end
