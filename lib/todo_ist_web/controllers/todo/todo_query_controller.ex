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

        # query =
        #   from todo in "todos",
        #     where: todo.user_id == type(^u_id, :binary_id),
        #     select: [:user_id, :title, :description, :id, :status, :priority, :complete_by]

        ai_query =
          from r in TodoIst.Relationship,
            join: t in TodoIst.Todo,
            on: r.object_id == t.id,
            left_join: assigned_relations in TodoIst.Relationship,
            on:
              assigned_relations.object_id == t.id and
                assigned_relations.predicate == "todo_assigned",
            left_join: assigned_users in TodoIst.User,
            on: assigned_users.id == assigned_relations.subject_id,
            where:
              (r.subject_id == ^user_id and r.predicate == "todo_assigned") or
                (t.user_id == ^user_id and r.predicate == "todo_assigned"),
            group_by: [
              t.id,
              t.title,
              t.status,
              t.description,
              t.priority,
              t.complete_by,
              t.user_id
            ],
            select: %{
              id: t.id,
              title: t.title,
              status: t.status,
              description: t.description,
              priority: t.priority,
              complete_by: t.complete_by,
              user_id: t.user_id,
              assigned_users: fragment("array_agg(?)", assigned_users.id)
            }

        repo = Repo.all(ai_query)
        # Jason.Formatter.pretty_print_to_iodata(repo)

        # data =
          #   query
          #   |> Repo.all()

          res = aggregate_results(repo)
          Logger.info("LOGGER: #{inspect(res)}")

        json(conn, %{success: res})

      _ ->
        json(conn, %{error: "failed"})
    end
  end

  # @enums ["todo", "review", in_progress, "completed"]

  defp aggregate_results(data, agg \\ %{todo: [], review: [], in_progress: [], completed: []})

  defp aggregate_results([], agg), do: agg

  defp aggregate_results([h | t], agg) do
    %{id: id, user_id: user_id, assigned_users: assigned_users} = h
    assigned_users = Enum.map(assigned_users, fn id -> cast!(id) end)
    h = %{h | id: cast!(id), user_id: cast!(user_id), assigned_users: assigned_users}

    case h.status do
      :todo ->
        # Logger.info(agg)

        %{todo: todos} = agg
        aggregate_results(t, %{agg | todo: [h | todos]})

      :in_progress ->
        %{in_progress: in_prog} = agg
        aggregate_results(t, %{agg | in_progress: [h | in_prog]})

      :review ->
        %{review: review} = agg

        aggregate_results(t, %{agg | review: [h | review]})

      :completed ->
        %{completed: completed} = agg
        aggregate_results(t, %{agg | completed: [h | completed]})
    end
  end
end
