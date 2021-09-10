defmodule SimpleBlog.Repo.Migrations.CreateReactions do
  use Ecto.Migration

  def change do
    create table(:reactions) do
      add :type, :integer
      add :comment_id, references(:comments, on_delete: :nothing)

      timestamps()
    end

    create index(:reactions, [:comment_id])
  end
end
