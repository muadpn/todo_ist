defmodule TodoIstWeb.Todo.TodoQueryController do
  alias TodoIst.Repo
  import Ecto.Query, only: [from: 2]
  import Ecto.UUID
  use TodoIstWeb, :controller
  require Logger

  def get_todo(conn, _data) do
    case Guardian.Plug.current_resource(conn) do
      %{:id => user_id} ->
        u_id = user_id

        query =
          from todo in "todos",
            where: todo.user_id == type(^u_id, :binary_id),
            select: [:user_id, :title, :description, :id, :status, :priority, :complete_by]

        data =
          query
          |> Repo.all()

        # data =
        # Enum.map(data, fn each ->
        #   each
        #   |> Map.update!(:id, &cast!/1)
        #   |> Map.update!(:user_id, &cast!/1)
        # end)

        res = aggregate_results(data)

        json(conn, %{success: res})

      _ ->
        json(conn, %{error: "failed"})
    end
  end

  # @enums ["todo", "review", in_progress, "completed"]

  defp aggregate_results(data, agg \\ %{todo: [], review: [], in_progress: [], completed: []})

  defp aggregate_results([], agg), do: agg

  defp aggregate_results([h | t], agg) do
    %{id: id, user_id: user_id} = h
    h = %{h | id: cast!(id), user_id: cast!(user_id)}

    case h.status do
      "todo" ->
        # Logger.info(agg)

        %{todo: todos} = agg
        aggregate_results(t, %{agg | todo: [h | todos]})

      "in_progress" ->
        %{in_progress: in_prog} = agg
        aggregate_results(t, %{agg | in_progress: [h | in_prog]})

      "review" ->
        %{review: review} = agg

        aggregate_results(t, %{agg | review: [h | review]})

      "completed" ->
        %{completed: completed} = agg
        aggregate_results(t, %{agg | completed: [h | completed]})
    end
  end
end
