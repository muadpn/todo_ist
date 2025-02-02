defmodule TodoIstWeb.User.UsersQueryController do
  use TodoIstWeb, :controller
  alias TodoIst.Relationship
  alias TodoIst.Repo
  alias TodoIst.Accounts
  # alias TodoIst.Repo
  import Ecto.Query
  require Logger

  def users_by_email_query(conn, %{"email" => email}) when is_binary(email) do
    case Guardian.Plug.authenticated?(conn) do
      true ->
        users = Accounts.Query.fetch_users_by_email(String.trim(email))

        conn
        |> send_resp(200, Jason.encode!(users))

      false ->
        send_resp(conn, 402, Jason.encode!(%{error: "Failed to Authenticate, Please Login"}))

      _ ->
        send_resp(conn, 500, Jason.encode!(%{error: "Server Error, Please try again."}))
    end
  end

  def fetch_pending_request(conn, _data) do
    %{"data" => %{"id" => user_id}} = Guardian.Plug.current_claims(conn)

    query =
      from r in TodoIst.Relationship,
        as: :relation_ship,
        join: u in TodoIst.User,
        on: r.subject_id == u.id,
        where: r.object_id == ^user_id and r.predicate == "sent_friend_request",
        where:
          not exists(
            from rr in TodoIst.Relationship,
              where:
                rr.subject_id == parent_as(:relation_ship).object_id and
                  rr.object_id == parent_as(:relation_ship).subject_id and
                  rr.predicate == "accepted_friend_request"
          ),
        select: %{id: u.id, name: u.name, email: u.email}

    data = Repo.all(query)

    send_resp(conn, 200, Jason.encode!(data))
  end

  def fetch_friends(conn, _data) do
    %{"data" => %{"id" => user_id}} = Guardian.Plug.current_claims(conn)
    data = Relationship.Queries.get_user_friends_list(user_id)
    send_resp(conn, 200, Jason.encode!(data))
  end
end
