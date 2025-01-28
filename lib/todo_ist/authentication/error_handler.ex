defmodule TodoIst.Authentication.ErrorHandler do
  import Plug.Conn

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, data, _opts) do
    IO.inspect(data)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, Jason.encode!(%{error: "NOT AUTHENTICATED"}))
  end

  def error_handler(conn) do
    IO.inspect("ERROR_HANDLER")
    IO.inspect(conn)
    conn
  end
end
