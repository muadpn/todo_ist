defmodule TodoIst.Messages.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "messages" do
    field :content, :string
    field :type, :string
    field :body, :map
    field :read_at, :utc_datetime

    belongs_to :sender, TodoIst.User, type: :binary_id
    belongs_to :receiver, TodoIst.User, type: :binary_id

    timestamps(type: :utc_datetime)
  end


  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :type, :body, :sender_id, :receiver_id])
    |> validate_required([:type, :sender_id, :receiver_id])
    |> validate_inclusion(:type, ["message", "todo"])
    |> validate_body_schema()
  end

  defp validate_body_schema(changeset) do
    case get_field(changeset, :type) do
      "todo" -> validate_todo_body(changeset)
      "message" -> validate_message_body(changeset)
      _ -> add_error(changeset, :type, "invalid message type")
    end
  end

  defp validate_todo_body(changeset) do
    case get_field(changeset, :body) do
      %{"title" => _title, "due_date" => _due_date} -> changeset
      _ -> add_error(changeset, :body, "invalid todo body schema")
    end
  end

  defp validate_message_body(changeset) do
    case get_field(changeset, :content) do
      nil -> add_error(changeset, :content, "content required for message type")
      _ -> changeset
    end
  end
end
