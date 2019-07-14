defmodule RSS.Repo do
  import Ecto.Query
  alias Jazz.{Repo, Feed, Post}

  def get_or_insert_feed(attrs) do
    case Repo.get_by(Feed, url: attrs.url) do
      nil ->
        Repo.insert(Feed.changeset(%Feed{}, attrs))
      f ->
        {:ok, f}
    end
  end

  def insert_posts_optimistic({post_attrs, feed_id}) do
        post_attrs
        |> Stream.map(&Map.put(&1, :feed_id, feed_id))
        |> Stream.map(&Post.changeset(%Post{}, &1))
        |> Enum.map(&Repo.insert(&1, on_conflict: :nothing))
  end

  def all_posts_from_feed(feed_id) do
    query = from p in Post, where: p.feed_id == ^feed_id, select: [:title, :id, :feed_title, :podcast, :saved], order_by: [desc: :id], limit: 1000
    Repo.all(query)
  end

  def all_unread_posts do
    query = from p in Post, where: p.read == false and p.saved == false, select: [:title, :id, :feed_title, :podcast, :saved], order_by: [desc: :id]
    Repo.all(query)
  end

  def all_saved_posts do
    query = from p in Post, where: p.saved and not p.podcast, select: [:title, :id, :feed_title, :podcast, :saved], order_by: [desc: :id]
    Repo.all(query)
  end

  def all_saved_podcasts do
    query = from p in Post, where: p.saved and p.podcast, select: [:title, :id, :feed_title, :podcast, :saved], order_by: [desc: :id]
    Repo.all(query)
  end

  def set_all_read(ids, read) do
    query = from(p in Post, where: p.id in ^ids)
    Repo.update_all(query, set: [read: read])
  end

  def set_read(id, read) do
    Repo.get!(Post, id)
    |> Post.set_read(read)
    |> Repo.update()
  end

  def toggle_saved(id) do
    Repo.get!(Post, id)
    |> Post.change_saved()
    |> Repo.update()
  end

  def toggle_podcast(id) do
    Repo.get!(Post, id)
    |> Post.toggle_podcast()
    |> Repo.update()
  end
end
