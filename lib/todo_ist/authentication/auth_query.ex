defmodule TodoIst.Authentication.AuthQuery do
  alias TodoIst.Guardian

  def get_auth_from_conn(conn) do
    case Guardian.Plug.current_claims(conn) do
      %{"data" => %{"id" => user_id, "name" => name, "email" => email}} ->
        {:ok, [user_id, email,name]}

      _ ->
        {:error, "User must be authenticated."}
    end
  end
end
