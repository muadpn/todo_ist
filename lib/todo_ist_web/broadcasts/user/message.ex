defmodule TodoIstWeb.Broadcasts.User.Message do
  alias TodoIstWeb.Endpoint

  @spec broadcast_chat_message(String.t(), String.t(), map()) :: :ok
  def broadcast_chat_message(to_user_id, from_user_id, message)
      when is_binary(to_user_id) and is_binary(from_user_id) and is_map(message) do
    Endpoint.broadcast(endpoint(to_user_id), "message:recieve", %{
      from: from_user_id,
      body: %{message: message}
    })
  end

  def broadcast_chat_message(_, _, _) do
    {:error, "Invalid Inputs received"}
  end

  @spec endpoint(String.t()) :: String.t()
  defp endpoint(to_user) do
    "user:" <> to_user
  end
end
