defmodule TodoIstWeb.Todo.TodoMutationController do
  use TodoIstWeb, :controller
  require Logger
  alias TodoIst.Guardian
  alias TodoIst.Repo
  alias TodoIst.Todo
  import Ecto.Query

  def add_todo(
        conn,
        %{
          "complete_by" => date,
          "description" => description,
          "priority" => priority,
          "status" => status,
          "title" => title
        }
      ) do
    %{"data" => %{"id" => user_id}} = Guardian.Plug.current_claims(conn)

    changeset =
      Todo.changeset(
        %TodoIst.Todo{},
        %{
          title: title,
          description: description,
          complete_by: parse_date(date),
          priority: String.to_atom(priority),
          status: String.to_atom(status),
          user_id: user_id
        }
      )

    case changeset.valid? do
      false ->
        get_first_error_message(changeset)
        |> send_error_response(conn)

      true ->
        # send_resp(conn, 200, Jason.encode!(%{success: "Inserted"}))

        case TodoIst.Repo.insert(changeset) do
          {:ok, todo} ->
            send_resp(
              conn,
              201,
              Jason.encode!(%{message: "Todo created successfully", todo: todo})
            )

          {:error, _reason} ->
            send_resp(conn, 500, Jason.encode!(%{error: "Failed to save to database"}))
        end

      _ ->
        send_resp(conn, 500, Jason.encode!(%{error: "Something went Wrong"}))
    end
  end

  defp parse_date(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _offset} ->
        DateTime.to_date(datetime)

      {:error, _reason} ->
        nil
    end
  end

  defp get_first_error_message(changeset) do
    changeset.errors
    # Get the first error tuple
    |> Enum.at(0)
    |> case do
      nil -> nil
      {_field, {message, _opts}} -> message
    end
  end

  defp send_error_response(errorMsg, conn) do
    send_resp(conn, 402, Jason.encode!(%{error: errorMsg}))
  end

  def update_todo_status(conn, %{"todoId" => todo_id, "newStatus" => new_status}) do
    %{"data" => %{"id" => user_id}} = Guardian.Plug.current_claims(conn)

    # case Guardian.Plug.current_claims(conn) do
    #   %{"data" => %{"id" => user_id}} -> send
    # end

    # todo = Repo.get_by(TodoIst.Todo, id: todo_id, user_id: user_id)

    # todo =
    #   Ecto.Changeset.change(Repo.get_by(TodoIst.Todo, id: todo_id, user_id: user_id), %{
    #     status: String.to_atom(new_status)
    #   })
    #   |> Repo.update()

    case Repo.get_by(TodoIst.Todo, id: todo_id, user_id: user_id) do
      nil ->
        Logger.info("UPDATING TODO")
        Logger.info("UPDATING TODO")
        {:error, :not_found}

      todo ->
        Logger.info("UPDATING TODO")
        Logger.info("UPDATING TODO")

        todo
        |> Ecto.Changeset.change(%{status: String.to_atom(new_status)})
        |> Repo.update()

        Logger.info("TODO: #{inspect(todo)}")

        send_resp(
          conn,
          201,
          Jason.encode!(%{message: "Todo created successfully", todo: todo})
        )

        # true ->
        #   send_resp(
        #     conn,
        #     201,
        #     Jason.encode!(%{error: "failed to update"})
        #   )
    end

    send_resp(
      conn,
      201,
      Jason.encode!(%{error: "failed to update"})
    )
  end

  def update_todo_status(conn, _data) do
    send_resp(conn, 400, Jason.encode!(%{error: "Invalid data"}))
  end

  # def update_todo(conn, data) do
  #   %{"data" => %{"id" => user_id}} = Guardian.Plug.current_claims(conn)
  #   # handle cases here in elixir way of doing things
  # end

  # def update_todo(conn, _data) do
  #   send_resp(conn, 200, Jason.encode!(%{error: "Invalid parameters"}))
  # end

  # FUNCTIONS THAT HANDLES UPDATE TOOD>>>>>>

  def update_todo(conn, data) do
    %{"data" => %{"id" => user_id}} = Guardian.Plug.current_claims(conn)

    case {Map.get(data, "id"), validate_update_params(data)} do
      {nil, _} ->
        conn
        |> send_resp(400, Jason.encode!(%{error: "Todo ID is required"}))

      {todo_id, {:ok, update_params}} ->
        # Find the todo and ensure it belongs to the user
        query =
          from t in Todo,
            where: t.id == ^todo_id and t.user_id == ^user_id

        case Repo.one(query) do
          nil ->
            conn
            |> send_resp(404, Jason.encode!(%{error: "Todo not found or unauthorized"}))

          todo ->
            # Apply the update
            case do_update_todo(todo, update_params) do
              {:ok, updated_todo} ->
                conn
                |> put_resp_content_type("application/json")
                |> send_resp(200, Jason.encode!(updated_todo))

              {:error, changeset} ->
                errors = format_changeset_errors(changeset)

                conn
                |> send_resp(422, Jason.encode!(%{errors: errors}))
            end
        end

      {_todo_id, {:error, reason}} ->
        conn
        |> send_resp(400, Jason.encode!(%{error: reason}))
    end
  end

  # Validate and filter update parameters
  defp validate_update_params(params) do
    allowed_fields = ["title", "description", "priority", "complete_by", "status"]
    update_params = Map.take(params, allowed_fields)
    # case
    Logger.info("COMPLETE: #{inspect(update_params["complete_by"])}")
    # update_params = %{update_params | "complete_by" => Date.from_iso8601!(update_params["complete_by"])}

    Logger.info("DATE STRING FOUND -> #{inspect(update_params)}")
    cond do
      map_size(update_params) == 0 ->
        {:error, "No valid update parameters provided"}

      has_invalid_date?(update_params) ->
        {:error, "Invalid date format for complete_by"}

      has_invalid_priority?(update_params) ->
        {:error, "Priority must be one of: very_low, low, medium, high, very_high, urgent"}

      has_invalid_status?(update_params) ->
        {:error, "Status must be one of: todo, in_progress, review, completed"}

      true ->
        {:ok, update_params}
    end
  end

  defp has_invalid_priority?(params) do
    case params["priority"] do
      nil ->
        false

      priority ->
        valid_priorities = ["very_low", "low", "medium", "high", "very_high", "urgent"]
        priority not in valid_priorities
    end
  end

  defp has_invalid_status?(params) do
    case params["status"] do
      nil ->
        false

      status ->
        valid_statuses = ["todo", "in_progress", "review", "completed"]
        status not in valid_statuses
    end
  end

  # DateTime.from_iso8601(date_string)
  defp has_invalid_date?(params) do
    case params["complete_by"] do
      nil ->
        false

      date_string ->
        case Date.from_iso8601(date_string) do
          {:ok, _} -> false
          {:error, _} -> true
        end
    end
  end

  defp do_update_todo(todo, params) do
    todo =
      todo
      |> Todo.changeset(params)
      |> Repo.update()

    Logger.info("UPDATE PARAM: #{inspect(todo)}")
    todo
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
