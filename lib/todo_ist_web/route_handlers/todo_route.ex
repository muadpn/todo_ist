defmodule TodoIstWeb.RouteHandlers.TodoRoute do
  use TodoIstWeb, :router
  alias Todo.{TodoQueryController, TodoMutationController}

  scope "/", TodoIstWeb do
    get "/get-todo", TodoQueryController, :get_todo
    post "/add-todo", TodoMutationController, :add_todo
    put "/update-status", TodoMutationController, :update_todo_status
    put "/update", TodoMutationController, :update_todo
  end
end
