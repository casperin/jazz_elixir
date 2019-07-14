defmodule DB.Update do
  import Ecto.Query
  alias Jazz.{Repo, Feed, Post, Link}

  def get_or_insert_feed(attrs) do
    case Repo.get_by(Feed, url: attrs.url) do
      nil ->
        Repo.insert(Feed.changeset(%Feed{}, attrs))
      f ->
        {:ok, f}
    end
  end

  def delete_feed(id) do
    feed = DB.Get.feed(id)
    Repo.delete(feed)
  end

  def insert_posts_optimistic({post_attrs, feed_id}) do
        post_attrs
        |> Stream.map(&Map.put(&1, :feed_id, feed_id))
        |> Stream.map(&Post.changeset(%Post{}, &1))
        |> Enum.map(&Repo.insert(&1, on_conflict: :nothing))
  end

  def set_all_read_post(ids, read) do
    query = from(p in Post, where: p.id in ^ids)
    Repo.update_all(query, set: [read: read])
  end

  def set_read_post(id, read) do
    Repo.get!(Post, id)
    |> Post.set_read(read)
    |> Repo.update()
  end

  def toggle_saved_post(id) do
    Repo.get!(Post, id)
    |> Post.change_saved()
    |> Repo.update()
  end

  def toggle_podcast_post(id) do
    Repo.get!(Post, id)
    |> Post.toggle_podcast()
    |> Repo.update()
  end

  def insert_link(url, title) do
    link = Link.changeset(%Link{}, %{ url: url, title: title})
    Repo.insert!(link)
  end

  def delete_link(id) do
    link = Repo.get!(Link, id)
    Repo.delete link 
  end
end
