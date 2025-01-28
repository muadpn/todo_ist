defmodule TodoIst.Relationship do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "relationships" do
    field :subject_id, :binary_id
    field :subject_table, :string
    field :predicate, :string
    field :object_id, :binary_id
    field :object_table, :string

    belongs_to :user, TodoIst.User, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  def changeset(relationship, attrs) do
    relationship
    |> cast(attrs, [:subject_id, :subject_table, :predicate, :object_id, :object_table, :user_id])
    |> validate_required([
      :subject_id,
      :subject_table,
      :predicate,
      :object_id,
      :object_table
    ])
  end
end
