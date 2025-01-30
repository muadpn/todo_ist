defmodule TodoIstWeb.Broadcasts.BroadcastUser do
  alias TodoIstWeb.Endpoint


  @doc """
  param_A -> Whom to send the updates to...
  param_b -> from whom the request is processed
  param_c -> Message to pass to to the user
  """
  @spec broadcast_user(String.t(), String.t(), String.t(), any()) :: :ok
  def broadcast_user(event_name, to_user_id, from_user_id, message)
  
      when is_binary(to_user_id) and is_binary(from_user_id) do


    Endpoint.broadcast(endpoint(to_user_id), event_name, %{
      from: from_user_id,
      body: message
    })
  end

  def broadcast_user(_, _, _, _) do
    {:error, "Invalid Inputs received"}
  end

  @spec endpoint(String.t()) :: String.t()
  defp endpoint(to_user) do
    "user:" <> to_user
  end
end
