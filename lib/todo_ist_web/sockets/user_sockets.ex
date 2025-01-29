defmodule TodoIstWeb.UserSockets do
  use Phoenix.Socket

  alias TodoIst.Guardian
  require Logger
  channel "user:*", TodoIstWeb.UserChannel

  def connect(%{"token" => token}, socket, _connect_info) do
    with {:ok, %{"data" => %{"id" => user_id}}} <- Guardian.decode_and_verify(token) do
      {:ok, assign(socket, :user_id, user_id)}
    else
      _ ->
        {:error, "UNAUTHORIZED FROM ELIXIR!"}
    end
  end

  # Assigns a unique ID to the socket for Presence tracking
  def id(socket), do: "user:#{socket.assigns.user_id}"
end
