defmodule Jazz.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :url, :string
      add :title, :string

      timestamps()
    end

    create unique_index(:feeds, [:url])
  end
end
