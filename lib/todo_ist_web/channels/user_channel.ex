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
  Phoenix.Presence

  def join("user:" <> user_id, _params, socket) do
    Logger.info("CONNECTED TO USER!!!!")

    if(user_id === socket.assigns.user_id) do
      send(self(), :after_join)
      {:ok, socket}
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
    Logger.info(inspect(message))

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
end
