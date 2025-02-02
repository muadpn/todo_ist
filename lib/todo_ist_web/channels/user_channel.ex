defmodule TodoIstWeb.UserChannel do
  alias TodoIst.Repo
  alias TodoIst.Messages.ChatMessage
  alias TodoIstWeb.Broadcasts.BroadcastUser
  alias TodoIst.Messages.ChatMessage, as: ChatSchema
  alias TodoIstWeb.Broadcasts.User.Message
  alias TodoIstWeb.Endpoint
  alias Phoenix.Socket.Broadcast
  alias Phoenix.Socket.Message
  require Logger
  use Phoenix.Channel
  alias TodoIstWeb.Presence
  # Phoenix.Presence

  def join("user:" <> user_id, _params, socket) do
    Logger.info("CONNECTED TO USER!!!!")

    if(user_id === socket.assigns.user_id) do
      friends = TodoIst.Relationship.Queries.get_user_friends_list(socket.assigns.user_id)

      friend_presences =
        Enum.map(friends, fn friend ->
          is_online =
            case Presence.get_by_key("user:#{friend.id}", friend.id) do
              # No presence data means offline
              [] -> false
              # Has presence data means online
              _ -> true
            end

          %{
            user_id: friend.id,
            is_online: is_online
          }
        end)

      process_after_join(socket)
      send(self(), :after_join)
      {:ok, %{initial_presences: friend_presences}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("send_message", %{"body" => body, "to" => to_user_id}, socket) do
    Endpoint.broadcast("user:#{to_user_id}", "new_message", %{
      from: socket.assigns.user_id,
      body: body
    })

    {:noreply, socket}
  end

  def handle_in("message:send", %{"body" => message, "to" => to_user_id}, socket) do
    Logger.info("MESSAGE RECEIVED #{inspect(message)}")

    # TodoIstWeb.Endpoint.broadcast(
    #   "user:#{to_user_id}",
    #   # event name that recipient will receive
    #   "new_message",
    #   %{
    #     from: socket.assigns.user_id,
    #     body: message
    #   }

    data =
      BroadcastUser.broadcast_user(
        "message:recieve",
        to_user_id,
        socket.assigns.user_id,
        message
      )

    Logger.info("DATA::#{inspect(data)}")

    new_message = %{
      content: message["content"],
      receiver_id: message["receiverId"],
      sender_id: message["senderId"],
      type: "message"
    }

    change_set = ChatSchema.changeset(%ChatMessage{}, new_message)

    case change_set do
      %{valid?: true} ->
        inserted = Repo.insert(change_set)
        Logger.info("INSERTED:: #{inspect(inserted)}")

        {:reply, :ok, socket}

      %{valid?: false} ->
        {:reply, :ok, socket}

      _ ->
        {:reply, :ok, socket}
    end
  end

  # Handle direct server-triggered messages
  def handle_in("request_server_message", %{"to" => to_user_id}, socket) do
    Endpoint.broadcast("user:#{to_user_id}", "server_message", %{
      message: "User #{socket.assigns.user_id} requested this"
    })

    {:reply, :ok, socket}
  end

  def handle_in("*", _, socket) do
    Logger.info("GOT SOME MESSAGE>...")
    {:reply, :ok, socket}
  end

  def handle_out("presence_diff", payload, socket) do
    Logger.info("Presence diff received: #{inspect(payload)}")

    # We'll let the terminate callback handle disconnections
    # This can handle other presence-related events if needed
    {:noreply, socket}
  end

  # Pheonix basic Needs
  def handle_info(
        %Message{topic: topic, event: "phx_leave"} = message,
        %{topic: topic, serializer: Jason, transport_pid: transport_pid} = socket
      ) do
    send(transport_pid, Jason.encode!(%{message: message}))
    {:stop, {:shutdown, :left}, socket}
  end

  def handle_info(
        %Broadcast{event: "phx_drain"},
        %{transport_pid: transport_pid} = socket
      ) do
    send(transport_pid, :socket_drain)
    {:stop, {:shutdown, :draining}, socket}
  end

  def handle_info({:DOWN, _, _, transport_pid, reason}, %{transport_pid: transport_pid} = socket) do
    reason = if reason == :normal, do: {:shutdown, :closed}, else: reason
    {:stop, reason, socket}
  end

  def handle_info(:after_join, socket) do
    Logger.info("User #{socket.assigns.user_id} has joined their channel.")
    {:noreply, socket}
  end

  defp process_after_join(socket) do
    try do
      {:ok, _} =
        Presence.track(socket, socket.assigns.user_id, %{
          online_at: System.system_time(:second),
          user_id: socket.assigns.user_id
        })

      # Track initial presence and notify friends
      friends = TodoIst.Relationship.Queries.get_user_friends_list(socket.assigns.user_id)

      # Add error handling for the broadcast
      Enum.each(friends, fn friend ->
        try do
          Endpoint.broadcast("user:#{friend.id}", "friends:active", %{
            user_id: socket.assigns.user_id,
            is_online: true
          })
        rescue
          e ->
            Logger.error("Error broadcasting presence to friend #{friend.id}: #{inspect(e)}")
        end
      end)
    rescue
      e ->
        Logger.error("Error in process_after_join: #{inspect(e)}")
        :ok
    end
  end

  def terminate(reason, socket) do
    Logger.info(
      "Channel terminated for user #{socket.assigns.user_id}. Reason: #{inspect(reason)}"
    )

    # Get list of user's friends
    friends = TodoIst.Relationship.Queries.get_user_friends_list(socket.assigns.user_id)

    # Broadcast offline status to all friends
    Enum.each(friends, fn friend ->
      Endpoint.broadcast("user:#{friend.id}", "friends:active", %{
        user_id: socket.assigns.user_id,
        is_online: false
      })
    end)

    # Remove presence
    Presence.untrack(socket, socket.assigns.user_id)

    :ok
  end


end
