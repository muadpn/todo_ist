defmodule TodoIstWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :todo_ist

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_todo_ist_key",
    signing_salt: "JWg4RrIR",
    same_site: "Lax"
  ]

  # socket "/socket", Phoenix.LiveView.Socket,
  #   websocket: [connect_info: [session: @session_options]],
  #   longpoll: [connect_info: [session: @session_options]]

  # [connect_info: [session: @session_options]]
  socket "/socket", TodoIstWeb.UserSockets,
    websocket: true,
    longpoll: false

  # socket "/ws", TodoIstWeb.DomainCounter,
  #   websocket: true,
  #   longpoll: false


    # websocket: [check_origin: ["http://localhost:5173", "https://yourdomain.com"]],
#
  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :todo_ist,
    gzip: false,
    only: TodoIstWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :todo_ist
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  # plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug TodoIstWeb.Router
end
