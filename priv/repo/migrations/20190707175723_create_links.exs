defmodule Jazz.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :url, :string
      add :title, :string

      timestamps()
    end
  end
end
