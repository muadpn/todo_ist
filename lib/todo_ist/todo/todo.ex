defmodule TodoIst.Todo do
  use Ecto.Schema
  import Ecto.Changeset

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

    belongs_to :created_by, TodoIst.User, type: :binary_id

    timestamps(type: :utc_datetime, inserted_at: :inserted_at, updated_at: :updated_at)
  end

  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :description, :complete_by, :priority, :status, :created_by_id])
    |> validate_required([:title])
    |> validate_length(:title, max: 255)
    |> validate_length(:description, max: 255)
  end
end
