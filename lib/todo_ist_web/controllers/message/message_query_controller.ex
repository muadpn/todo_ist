defmodule TodoIstWeb.Message.MessageQueryController do
  use TodoIstWeb, :controller
  alias TodoIst.Messages.Query
  alias TodoIst.Authentication.AuthQuery
  require Logger

  def get_user_message(conn, _data) do
    case AuthQuery.get_auth_from_conn(conn) do
      {:ok, [user_id, email, name]} ->

        data = Query.get_user_messages(user_id)

        send_resp(conn, 200, Jason.encode!(%{id: user_id, email: email, name: name, data: data}))

      {:error, _} ->
        json(conn, %{error: "UNAUTHORIZED"})

      _ ->
        json(conn, %{error: "UNAUTHORIZED"})
    end
  end
end
