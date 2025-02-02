defmodule TodoIst.Presence do
  use Phoenix.Presence,
    otp_app: :todo_ist,
    pubsub_server: TodoIst.PubSub
end
