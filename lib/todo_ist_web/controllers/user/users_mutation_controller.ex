defmodule TodoIstWeb.User.UsersMutationController do
  use TodoIstWeb, :controller
  alias Ecto.Repo
  alias TodoIst.Relationship
  alias TodoIst.Guardian
  alias TodoIst.Repo
  import Ecto.Query
  import Ecto.UUID
  require Logger

  def send_friend_request(conn, data) do
    %{"data" => %{"id" => user_id}} = Guardian.Plug.current_claims(conn)

    changeset =
      Relationship.changeset(
        %Relationship{},
        %{
          subject_id: cast!(user_id),
          subject_table: "users",
          predicate: "sent_friend_request",
          object_id: data["id"],
          object_table: "users",
          user_id: cast!(user_id)
        }
      )
      Logger.info("CHANGESET: #{inspect(changeset)}")
    # , on_conflict: :nothing
    case changeset do
      %{valid?: true} ->
        inserted = Repo.insert(changeset, on_conflict: :nothing)
        Logger.info("INSERTED")
        Logger.info(inspect(inserted))
        send_resp(conn, 200, Jason.encode!(%{success: "Friend request send successfully"}))

      %{valid?: false} ->
        Logger.info("Validation FAILED")

        send_resp(conn, 200, Jason.encode!(%{error: "Didn't find friend"}))

      _ ->
        Logger.info("ERROR DIDN't find any")
        send_resp(conn, 500, Jason.encode!(%{message: "FAILED"}))
    end

    Logger.info(inspect(changeset), label: "CHANGE SET")
    send_resp(conn, 200, Jason.encode!(%{success: "Friend request send successfully"}))
  end

  def accept_friend_request(conn, %{"accept_friend_id" => accept_friend_id}) do
    %{"data" => %{"id" => user_id}} = Guardian.Plug.current_claims(conn)

    query =
      from r in TodoIst.Relationship,
        where:
          r.subject_id == ^cast!(accept_friend_id) and
            (r.object_id == ^cast!(user_id) and
               r.predicate == "sent_friend_request"),
        select: %{
          id: type(r.id, :binary_id),
          subject_id: type(r.subject_id, :binary_id),
          object_id: type(r.object_id, :binary_id),
          user_id: type(r.user_id, :binary_id),
          subject_table: r.subject_table,
          object_table: r.subject_table
        }

    # select: [:id, :subject_id, :object_id, :subject_table,:object_table,:predicate,:user_id]
    data = Repo.exists?(query)

    case data do
      true ->
        changeset =
          Relationship.changeset(
            %Relationship{},
            %{
              subject_id: cast!(user_id),
              subject_table: "users",
              predicate: "accepted_friend_request",
              object_id: cast!(accept_friend_id),
              object_table: "users",
              user_id: cast!(user_id)
            }
          )

        case changeset do
          %{valid?: true} ->
            inserted = Repo.insert(changeset, on_conflict: :nothing)
            Logger.info(inspect(inserted))
            send_resp(conn, 200, Jason.encode!(%{success: "Friend request send successfully"}))

          %{valid?: false} ->
            Logger.info("Validation FAILED")
            send_resp(conn, 200, Jason.encode!(%{error: "Didn't find friend"}))

          _ ->
            Logger.info("ERROR DIDN't find any")
            send_resp(conn, 500, Jason.encode!(%{message: "FAILED"}))
        end

      false ->
        send_resp(conn, 404, Jason.encode!(%{error: "Failed to find the relationship"}))

      _ ->
        send_resp(conn, 500, Jason.encode!(%{error: "Server failed to verify the request"}))
    end
  end
end
