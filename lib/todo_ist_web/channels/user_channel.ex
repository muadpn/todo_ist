defmodule TodoIstWeb.UserChannel do
  alias TodoIstWeb.Broadcasts.User
  alias TodoIstWeb.Endpoint
  alias Phoenix.Socket.Broadcast
  alias Phoenix.Socket.Message
  use Phoenix.Channel

  Phoenix.Presence
  # alias TodoIstWeb.Presence
  require Logger

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
    User.Message.broadcast_chat_message(to_user_id, socket.assigns.user_id, message)
    {:noreply, socket}
  end

  # Handle direct server-triggered messages
  def handle_in("request_server_message", %{"to" => to_user_id}, socket) do
    Endpoint.broadcast("user:#{to_user_id}", "server_message", %{
      message: "User #{socket.assigns.user_id} requested this"
    })

    {:reply, :ok, socket}
  end

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

  # def handle_info(:after_join, socket) do
  #   # Presence.
  #   {:ok, _} =
  #     push(socket, "presence_state", Presence.list(TodoIstWeb, socket))

  #   {:noreply, socket}
  # end

  # Listen for friend requests
  # def handle_in("send_friend_request", %{"friend_id" => friend_id}, socket) do
  #   broadcast!(socket, "new_friend_request", %{from: socket.assigns.user_id, to: friend_id})
  #   {:noreply, socket}
  # end
end

# defmodule TodoIstWeb.UserSocket do
#   use Phoenix.Socket

#   ## Define a channel for users
#   channel "user:*", TodoIstWeb.UserChannel

#   def connect(%{"token" => token}, socket, _connect_info) do
#     case Guardian.decode_and_verify(token) do
#       {:ok, claims} ->
#         {:ok, assign(socket, :user_id, claims["sub"])}

#       {:error, _reason} ->
#         :error
#     end
#   end

#   def id(socket), do: "user:#{socket.assigns.user_id}"
# end
