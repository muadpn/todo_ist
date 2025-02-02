defmodule TodoIstWeb.Presence do
  use Phoenix.Presence,
    otp_app: :todo_ist,
    pubsub_server: TodoIst.PubSub
  require Logger
  def init(_opts) do
    # Ensure the table is created when the presence module starts
    {:ok, %{}}
  end

  def handle_metas(_topic, %{joins: joins, leaves: leaves}, _presences, state) do
    for {key, %{metas: metas}} <- joins do
      Logger.debug("#{key} joined with metas: #{inspect(metas)}")
    end

    for {key, %{metas: metas}} <- leaves do
      Logger.debug("#{key} left with metas: #{inspect(metas)}")
    end

    {:ok, state}
  end
end
