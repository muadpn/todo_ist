defmodule TodoIst.Relationship.Queries do
  @moduledoc """
  This Modules handle queries for the Relationship's that are to be extracted within its context.
  """

    alias TodoIst.Repo
    import Ecto.Query
    import Ecto.UUID

  @doc """
  From represents who initialized the request
  To represent who it received the request to.

  always To will be there as a predicate to avoid confusion
  send_friend_request_to
  user_a sent_friend_request to user_B
  """
  def is_friend_request_present(request_from, request_to)
      when is_binary(request_from) and is_binary(request_to) do
    query =
      from r in TodoIst.Relationship,
        where:
          r.subject_id == ^cast!(request_from) and
            (r.object_id == ^cast!(request_to) and
               r.predicate == "sent_friend_request"),
        select: %{
          id: type(r.id, :binary_id),
          subject_id: type(r.subject_id, :binary_id),
          object_id: type(r.object_id, :binary_id),
          user_id: type(r.user_id, :binary_id),
          subject_table: r.subject_table,
          object_table: r.subject_table
        }

    case Repo.exists?(query) do
      true -> {:ok, "user request exists"}
      false -> {:error, "User request not found"}
    end
  end

  def is_friend_request_present(_, _) do
    {:error, "Could'nt process because of invalid data"}
  end
end
