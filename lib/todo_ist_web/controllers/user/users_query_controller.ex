defmodule TodoIstWeb.User.UsersQueryController do
  use TodoIstWeb, :controller
  alias TodoIst.Repo
  # alias TodoIst.Repo
  import Ecto.Query
  require Logger

  def users_by_email_query(conn, %{"email" => email}) when is_binary(email) do
    case Guardian.Plug.authenticated?(conn) do
      true ->
        users = fetch_user_by_email(String.trim(email))

        conn
        |> send_resp(200, Jason.encode!(users))

      false ->
        send_resp(conn, 402, Jason.encode!(%{error: "Failed to Authenticate, Please Login"}))

      _ ->
        send_resp(conn, 500, Jason.encode!(%{error: "Server Error, Please try again."}))
    end
  end

  def fetch_user_by_email(email) do
    query =
      from u in "users",
        where: ilike(u.email, ^"%#{email}%"),
        select: %{
          id: type(u.id, :binary_id),
          email: u.email,
          name: u.name,
          inserted_at: u.inserted_at
        }

    Repo.all(query)
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

    query =
      from r in TodoIst.Relationship,
        join: u in TodoIst.User,
        on: u.id == r.subject_id or u.id == r.object_id,
        where:
          (r.subject_id == ^user_id or r.object_id == ^user_id) and
            r.predicate == "accepted_friend_request",
        # Exclude self from the result
        where: u.id != ^user_id,
        select: %{id: u.id, name: u.name, email: u.email}

    data = Repo.all(query)

    send_resp(conn, 200, Jason.encode!(data))
  end

  # @email_regex ~r/^[^\s]+@[^\s]+\.[^\s]+$/
  # defp validateEmail?(email) when is_binary(email) do
  #   case Regex.match?(@email_regex, email) do
  #     true -> {:ok, email: email}
  #     false -> {:error, message: "Invalid email"}
  #   end
  # end
end
