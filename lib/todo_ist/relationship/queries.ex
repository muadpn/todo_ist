defmodule TodoIst.Relationship.Queries do
  @moduledoc """
  This Modules handle queries for the Relationship's that are to be extracted within its context.
  """

  require Logger
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

  def get_user_friends_list(user_id) when is_binary(user_id) do
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

    Repo.all(query)
  end

  def get_user_friends_list(_) do
    nil
  end

  def verify_all_are_friends?(user_ids, cur_user_id)
      when is_list(user_ids) and is_binary(cur_user_id) do
    # Convert strings to UUIDs and get all possible pairs
    user_id_list = Enum.map(user_ids, fn id -> cast!(id) end)
    current_user_id = cast!(cur_user_id)
    Logger.info(inspect(current_user_id))
    # Query to check if all users exist and are friends with current user
    query =
      from r in TodoIst.Relationship,
        where: r.predicate == "accepted_friend_request",
        where:
          (r.subject_id == ^current_user_id and r.object_id in ^user_id_list) or
            (r.object_id == ^current_user_id and r.subject_id in ^user_id_list),
        select:
          fragment(
            "CASE
            WHEN ? = ? THEN ?
            ELSE ?
            END",
            type(r.object_id, :binary_id),
            type(r.user_id, :binary_id),
            type(r.object_id, :binary_id),
            type(r.subject_id, :binary_id)
          )

    # Get the list of friend IDs from the relationship table
    friend_ids = Repo.all(query)
    new_id = Enum.map(friend_ids, fn friends -> cast!(friends) end)
    # Convert the friend_ids to a MapSet for efficient comparison

    actual_friends = MapSet.new(new_id)
    # Convert the input ids to a MapSet for comparison
    expected_friends = MapSet.new(user_id_list)
    Logger.info("ACTUAL FRIENDS #{inspect(actual_friends)}")

    cond do
      # Check if we found all the friendships we're looking for
      MapSet.size(actual_friends) == length(user_id_list) and
          MapSet.equal?(actual_friends, expected_friends) ->
        {:ok, "All users are friends"}

      # If we didn't find all friendships, check which users aren't friends
      true ->
        missing_friends = MapSet.difference(expected_friends, actual_friends)
        {:error, "Not friends with users: #{Enum.join(missing_friends, ", ")}"}
    end
  end

  def verify_all_are_friends?(_) do
    {:error, "Invalid input data"}
  end
end
