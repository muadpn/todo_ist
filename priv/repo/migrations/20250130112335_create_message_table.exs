defmodule TodoIst.Repo.Migrations.CreateMessageTable do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :sender_id, references(:users, type: :uuid, on_delete: :nothing), null: false
      add :receiver_id, references(:users, type: :uuid, on_delete: :nothing), null: false
      add :content, :text
      add :type, :string, null: false
      add :body, :jsonb, default: fragment("'{}'::jsonb")
      add :read_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:sender_id])
    create index(:messages, [:receiver_id])
    create index(:messages, [:type])
    create index(:messages, [:sender_id, :receiver_id])
  end
end
