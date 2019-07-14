defmodule Jazz.Feed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feeds" do
    field :title, :string, null: false
    field :url, :string, null: false

    timestamps()
  end

  @doc false
  def changeset(feed, attrs) do
    feed
    |> cast(attrs, [:url, :title])
    |> validate_required([:url, :title])
    |> unique_constraint(:url)
  end
end
