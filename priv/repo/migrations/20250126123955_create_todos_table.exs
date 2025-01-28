defmodule TodoIst.Repo.Migrations.CreateTodosTable do
  use Ecto.Migration

  def change do
    # Create enum types
    execute "CREATE TYPE priority AS ENUM ('very_low', 'low', 'medium', 'high', 'very_high', 'urgent')",
            "DROP TYPE IF EXISTS priority"

    execute "CREATE TYPE todo_status AS ENUM ('todo', 'in_progress', 'review', 'completed')",
            "DROP TYPE IF EXISTS todo_status"

    create table(:todos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, size: 255, null: false
      add :description, :string, size: 255
      add :complete_by, :date
      add :priority, :priority, default: "medium"
      add :status, :todo_status, default: "todo"
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime, inserted_at: :inserted_at, updated_at: :updated_at)
    end

    # Indexing for todos
    create index(:todos, [:user_id])
    create index(:todos, [:status])
    create index(:todos, [:priority])
    create index(:todos, [:complete_by])
    create index(:todos, [:inserted_at])
    create index(:todos, [:updated_at])
  end
end
