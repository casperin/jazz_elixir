defmodule Jazz.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :guid, :string
      add :feed_title, :string
      add :read, :boolean, default: false
      add :saved, :boolean, default: false
      add :podcast, :boolean, default: false
      add :title, :string, null: false
      add :link, :string
      add :content, :text
      add :feed_id, references(:feeds)

      timestamps()
    end

    create unique_index(:posts, [:guid])
  end
end
