defmodule JazzWeb.FeedController do
  use JazzWeb, :controller
  alias Jazz.{Repo, Feed}

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      feeds: Repo.all(Feed), page: "feeds"
    )
  end

  def show(conn, %{"id" => id}) do
    case Repo.get(Feed, id) do
      nil ->
        conn
        |> put_flash(:error, "Could not find feed with id #{id}")
        |> redirect(to: Routes.feed_path(conn, :index))

      feed ->
        render(
          conn,
          "show.html",
          feed: feed,
          posts: RSS.Repo.all_posts_from_feed(feed.id),
          page: feed.title
        )
    end
  end

  def preview(conn, %{"url" => url}) do
    case RSS.Get.fetch(url) do
      {:ok, feed, posts} ->
        conn
        |> render("preview.html", feed: feed, posts: posts, page: "Preview: #{feed.title}")

      {_, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: Routes.feed_path(conn, :index))

    end
  end

  def create(conn, %{"url" => url}) do
    case RSS.Get.fetch(url) do
      {:ok, feed_attr, post_attrs} ->
        msg = case RSS.Repo.get_or_insert_feed(feed_attr) do
          {:ok, feed} ->
            IO.inspect post_attrs
            x = RSS.Repo.insert_posts_optimistic({post_attrs, feed.id})
            IO.inspect x
            "#{feed.title} saved"

          {:error, msg} ->
            IO.inspect msg
            "Something went wrong"
        end

        conn
        |> put_flash(:info, msg)
        |> redirect(to: Routes.feed_path(conn, :index))

      {_, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: Routes.feed_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    feed = Repo.get!(Feed, id)
    case Repo.delete feed do
      {:ok, _} ->
        conn
        |> put_flash(:info, "The feed will miss you")
        |> redirect(to: Routes.feed_path(conn, :index))
      _ ->
        conn
        |> put_flash(:error, "Couldn't unsubscribe from the feed :(")
        |> render("show.html", id: id)
    end
  end
end
