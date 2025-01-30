defmodule TodoIstWeb.Broadcasts.User.Friends do
  alias TodoIstWeb.Endpoint

  @doc """
  param_A -> Whom to send the updates to...
  param_b -> from whom the request is processed
  param_c -> Message to pass to to the user
  """
  @spec broadcast_friend_accepted(String.t(), String.t(), map()) :: :ok
  def broadcast_friend_accepted(to_user_id, from_user_id, message)
      when is_binary(to_user_id) and is_binary(from_user_id) and is_map(message) do
    Endpoint.broadcast(endpoint(to_user_id), "friend:accept", %{
      from: from_user_id,
      body: %{user: message}
    })
  end

  def broadcast_friend_accepted(_, _, _) do
    {:error, "Invalid Inputs received"}
  end

  @spec endpoint(String.t()) :: String.t()
  defp endpoint(to_user) do
    "user:" <> to_user
  end
end
