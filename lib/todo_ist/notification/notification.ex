defmodule TodoIst.Notification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "notifications" do
    field :type, :string
    field :context, :map
    field :is_read, :boolean, default: false
    field :priority, :integer, default: 0

    belongs_to :actor, TodoIst.User, type: :binary_id
    belongs_to :recipient, TodoIst.User, type: :binary_id

    field :deleted_at, :utc_datetime
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime, inserted_at: :inserted_at, updated_at: :updated_at)
  end

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:type, :context, :is_read, :priority, :actor_id, :recipient_id, :deleted_at, :expires_at])
    |> validate_required([:type, :recipient_id])
    |> validate_length(:type, max: 50)
  end
end
