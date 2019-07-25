defmodule Jazz.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :url, :string
    field :title, :string
    field :comment, :string

    timestamps()
  end

  def changeset(link, attrs) do
    link
    |> cast(attrs, [:url, :title, :comment])
    |> validate_required([:url, :title])
  end
end
