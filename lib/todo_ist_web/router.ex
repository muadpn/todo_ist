defmodule TodoIstWeb.Router do
  use TodoIstWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TodoIstWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: ["http://localhost:3000"]
  end

  scope "/", TodoIstWeb do
    pipe_through :browser
    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  scope "/api", TodoIstWeb do
    pipe_through :api

    forward "/auth", AuthRouter
    forward "/todo", TodoRouter
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:todo_ist, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
