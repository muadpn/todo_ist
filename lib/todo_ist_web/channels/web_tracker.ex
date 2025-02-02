defmodule TodoIstWeb.WebTracker do
  use Phoenix.Channel
  alias TodoIst.Presence
  require Logger

  def join("website:" <> domain, _params, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :domain, domain)}
  end

  def handle_info(:after_join, socket) do
    domain = socket.assigns.domain
    user_id = socket.assigns.user_id

    {:ok, _} =
      Presence.track(socket, domain, %{
        online_at: inspect(System.system_time(:second)),
        user_id: user_id
      })

    presence_list = Presence.list(socket)
    Logger.info(inspect(presence_list))
    domain_presence = Map.get(presence_list, domain, %{metas: []})

    push(socket, "presence_state", %{
      count: length(domain_presence.metas)
    })

    {:noreply, socket}
  end

  intercept ["presence_diff"]
  
  def handle_out("presence_diff", diff, socket) do
    domain = socket.assigns.domain

    joins = Map.get(diff.joins, domain, %{metas: []})
    leaves = Map.get(diff.leaves, domain, %{metas: []})

    domain_diff = %{
      count_change: length(joins.metas) - length(leaves.metas)
    }
    Logger.info("CURRENT COUNT: #{inspect(domain_diff)}")
    # broadcast!(socket, "presence_diff", domain_diff)
    push(socket, "presence_diff", domain_diff)
    {:noreply, socket}
  end
end
