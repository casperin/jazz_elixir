defmodule DB.Get do
  import Ecto.Query
  alias Jazz.{Repo, Feed, Post, Link}

  def post(id) do
    Repo.get(Post, id)
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

  def all_feeds do
    Repo.all(Feed)
  end

  def feed(id) do
    Repo.get(Feed, id)
  end

  def all_posts_from_feed(feed_id) do
    query = from p in Post, where: p.feed_id == ^feed_id, select: [:title, :id, :feed_title, :podcast, :saved], order_by: [desc: :id], limit: 1000
    Repo.all(query)
  end

  def all_links do
    Repo.all(Link)
  end
end
