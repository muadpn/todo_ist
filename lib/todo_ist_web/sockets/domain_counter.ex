defmodule TodoIstWeb.DomainCounter do
  use Phoenix.Socket

  # Channels
  channel "website:*", TodoIstWeb.WebTracker

  @impl true
  def connect(params, socket, _connect_info) do
    {:ok, assign(socket, :user_id, params["user_id"])}
  end

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
