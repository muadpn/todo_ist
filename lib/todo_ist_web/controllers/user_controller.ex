defmodule TodoIstWeb.UserController do
  require Logger
  alias TodoIst.Guardian
  use TodoIstWeb, :controller

  def get_user(conn, _data) do
    Logger.info(conn)

    case Guardian.Plug.current_claims(conn) do
      nil -> json(conn, %{error: "UNAUTHORIZED"})
      current_user -> json(conn, %{data: current_user})
    end
  end
end
