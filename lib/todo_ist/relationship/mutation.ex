defmodule TodoIst.Relationship.Mutation do
  alias TodoIst.Relationship
  alias TodoIst.Repo
  import Ecto.Query
  import Ecto.UUID

  # @relationship [:sent_friend_request]

  @doc """
  from user accepted friend request to to_user
  user a who received the request accepted the request from user B
  user who received the friend request and need to accept the request initialized by user_b
  """
  def accept_friend_request(from_user, to_user)
      when is_binary(from_user) and is_binary(to_user) do
    Relationship.changeset(
      %Relationship{},
      %{
        subject_id: cast!(from_user),
        subject_table: "users",
        predicate: "accepted_friend_request",
        object_id: cast!(to_user),
        object_table: "users",
        user_id: cast!(from_user)
      }
    )
    |> validate_and_insert_changeset
  end

  defp validate_and_insert_changeset(changeset) do
    case changeset do
      %{valid?: true} ->
        Repo.insert(changeset, on_conflict: :nothing)
        {:ok, "Successfully Inserted to database"}

      # Endpoint.broadcast("user:#{accept_friend_id}", "friend:accepted", %{
      #   from: user_id,
      #   body: %{
      #     user: %{
      #       id: user_id,
      #       name: name,
      #       email: email
      #     }
      #   }
      # })

      %{valid?: false} ->
        {:error, "error validating friend request."}

      _ ->
        {:error, "Something unexpected occured"}
    end
  end
end
