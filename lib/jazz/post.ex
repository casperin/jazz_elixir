defmodule Jazz.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :content, :string
    field :feed_title, :string
    field :guid, :string, unique: true
    field :link, :string
    field :read, :boolean, default: false
    field :saved, :boolean, default: false
    field :podcast, :boolean, default: false
    field :title, :string
    belongs_to :feed, Jazz.Feed

    timestamps()
  end

  def changeset(post, attrs) do
    post
    |> cast(attrs, [:guid, :feed_title, :feed_id, :read, :saved, :podcast, :title, :link, :content])
    |> validate_required([:guid, :feed_title, :feed_id, :title, :link])
  end

  def set_read(post, read) do
    post
    |> change(read: read)
  end

  def change_saved(post) do
    post
    |> change(saved: !post.saved, read: true)
  end

  def toggle_podcast(post) do
    post
    |> change(podcast: !post.podcast, saved: true, read: true)
  end

  def change_podcast(post) do
    post
    |> change(podcast: !post.podcast, read: true)
  end
end
