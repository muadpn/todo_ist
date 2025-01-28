defmodule TodoIstWeb.UserController do
  alias TodoIst.Guardian
  use TodoIstWeb, :controller

  def get_user(conn, _data) do
    case Guardian.Plug.current_claims(conn) do
      nil -> json(conn, %{error: "UNAUTHORIZED"})
      current_user -> json(conn, %{data: current_user})
    end
  end
end
