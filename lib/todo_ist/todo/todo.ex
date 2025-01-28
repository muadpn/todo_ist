defmodule TodoIst.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  alias TodoIst.User
  @primary_key {:id, :binary_id, autogenerate: true}
  @derive {Jason.Encoder, only: [:id, :title, :description, :complete_by, :priority, :status]}

  schema "todos" do
    field :title, :string
    field :description, :string
    field :complete_by, :date

    field :priority, Ecto.Enum,
      values: [:very_low, :low, :medium, :high, :very_high, :urgent],
      default: :medium

    field :status, Ecto.Enum,
      values: [:todo, :in_progress, :review, :completed],
      default: :todo

    # Add this line
    # field :user_id, :binary_id
    belongs_to(:created_by, User, foreign_key: :user_id, type: :binary_id)

    timestamps(type: :utc_datetime, inserted_at: :inserted_at, updated_at: :updated_at)
  end


  def changeset(todo, attrs) do
    change_set_error = fn field, _meta ->
      case field do
        :status -> "Status must be any of todo, in_progress, review, completed "
        :priority -> "Priority must be very_low, low, medium, high, very_high, urgent"
        _ -> nil
      end
    end

    todo
    |> cast(attrs, [:title, :description, :complete_by, :priority, :status, :user_id])
    # |> cast_assoc(:created_by)
    |> validate_required([:title])
    |> validate_length(:title, min: 3, message: "Title should be at-least 3 characters long")
    |> validate_length(:title, max: 255, message: "Title cannot exceed 255 characters")
    |> validate_length(:description,
      max: 254,
      message: "Description cannot exceed 254 characters"
    )
    |> validate_inclusion(:priority, [:very_low, :low, :medium, :high, :very_high, :urgent],
      message: "Invalid priority value"
    )
    |> validate_inclusion(:status, [:todo, :in_progress, :review, :completed],
      message: "Invalid status value"
    )
    |> validate_custom_messages(change_set_error)
  end

  defp validate_custom_messages(changeset, error_func) do
    Enum.reduce(changeset.errors, changeset, fn
      {field, {_message, _opts}} = _error, changeset ->
        custom_message = error_func.(field, changeset)

        if custom_message do
          add_error(changeset, field, custom_message)
        else
          changeset
        end
    end)
  end
end
