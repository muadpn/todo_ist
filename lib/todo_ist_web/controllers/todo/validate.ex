defmodule TodoIstWeb.Todo.Validate do
  require Logger
  alias TodoIst.Todo

  def validate_todo_change_set(title, description, date, priority, status, user_id) do

    changeset = Todo.changeset(
        %Todo{},
        %{
          title: title,
          description: description,
          complete_by: parse_date(date),
          priority: String.to_atom(priority),
          status: String.to_atom(status),
          user_id: user_id
        }
      )
    Logger.info("LOGGER_ #{inspect(changeset)}")
    case changeset.valid? do
      false ->
        {:error, get_first_error_message(changeset)}
      true ->
        {:ok, changeset}
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

  defp parse_date(date_string) do
    case DateTime.from_iso8601(date_string) do
      {:ok, datetime, _offset} ->
        DateTime.to_date(datetime)

      {:error, _reason} ->
        nil
    end
  end
end
