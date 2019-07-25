defmodule Jazz.Repo.Migrations.LinkAddCommentColumn do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add :comment, :text
    end
  end
end
