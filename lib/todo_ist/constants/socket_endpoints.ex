defmodule TodoIst.Constants.SocketEndpoints do
  @endpoints %{
    message: %{
      receive: "message:receive",
      send: "message:send"
    },
    friend: %{
      request: "friend:request",
      accept: "friend:accept"
    }
  }

  def event_path(path), do: get_in(@endpoints, path)
end
