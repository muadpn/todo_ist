defmodule TodoIst.Messages.Query do
  require Logger
  alias TodoIst.Messages.ChatMessage
  alias TodoIst.Repo
  import Ecto.Query
  import Ecto.UUID

  def get_user_messages(user_id) do
    query =
      from p in ChatMessage,
        where: p.sender_id == ^cast!(user_id) or p.receiver_id == ^cast!(user_id),
        select: %{
          sender_id: type(p.sender_id, :binary_id),
          receiver_id: type(p.receiver_id, :binary_id),
          id: type(p.id, :binary_id),
          content: p.content,
          body: p.body,
          type: p.type,
          inserted_at: p.inserted_at
        }

    organize_message(Repo.all(query), user_id)
  end

  # Main entry point for message organization
  defp organize_message(messages, user_id) when is_list(messages) do
    messages
    |> Enum.reduce(%{}, fn message, acc ->
      # Determine the friend_id (the other party in the conversation)
      Logger.info("DATA: #{inspect(message.inserted_at)}")
      friend_id = get_friend_id(message, user_id)

      # Convert the message to the expected format
      formatted_message = %{
        id: message.id,
        senderId: message.sender_id,
        receiverId: message.receiver_id,
        type: message.type,
        body: message.body,
        content: message.content,
        inserted_at: message.inserted_at
      }

      # Update the accumulator with the new message
      Map.update(acc, friend_id, [formatted_message], fn existing_messages ->
        existing_messages ++ [formatted_message]
      end)
    end)
  end

  # Fallback for empty or invalid input
  defp organize_message(_, _), do: %{}

  # Helper function to determine the friend_id
  defp get_friend_id(message, user_id) do
    cond do
      message.sender_id == user_id -> message.receiver_id
      message.receiver_id == user_id -> message.sender_id
      true -> nil
    end
  end
end
