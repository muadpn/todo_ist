defmodule TodoIst.Repo.Migrations.CreateRelationshipsTable do
  use Ecto.Migration

  def change do
    create table(:relationships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :subject_id, :binary_id
      add :subject_table, :string, size: 255
      add :predicate, :string, size: 255
      add :object_id, :binary_id
      add :object_table, :string, size: 255
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all, on_update: :update_all ), null: true

      timestamps(type: :utc_datetime)
    end

    create index(:relationships, [:subject_id])
    create index(:relationships, [:object_id])
    create index(:relationships, [:user_id])
    create index(:relationships, [:subject_id, :predicate])
    create index(:relationships, [:object_id, :predicate])

    # Composite unique index to prevent duplicate relationships
    create unique_index(:relationships, [:subject_id, :predicate, :object_id], name: :idx_relationships_unique)
  end
end
