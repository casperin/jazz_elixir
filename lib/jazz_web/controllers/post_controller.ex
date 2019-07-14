defmodule JazzWeb.PostController do
  use JazzWeb, :controller
  alias Jazz.{Repo, Post}

  # unread posts
  def index(conn, _params) do
    render(
      conn,
      "index.html",
      posts: RSS.Repo.all_unread_posts,
      page: "unread"
    )
  end

  # saved
  def saved(conn, _params) do
    render(
      conn,
      "saved.html",
      posts: RSS.Repo.all_saved_posts,
      page: "saved"
    )
  end

  # saved
  def podcasts(conn, _params) do
    render(
      conn,
      "podcasts.html",
      posts: RSS.Repo.all_saved_podcasts,
      page: "podcasts"
    )
  end

  # See specific post
  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    render(
      conn,
      "show.html",
      post: post,
      page: post.title
    )
  end

  def set_read(conn, %{"id" => id}) do
    RSS.Repo.set_read(id, true)
    redirect(conn, to: Routes.post_path(conn, :index))
  end

  def toggle_saved(conn, %{"id" => id, "to" => to}) do
    RSS.Repo.toggle_saved(id)
    redirect(conn, to: Routes.post_path(conn, get_path(to)))
  end

  def toggle_podcast(conn, %{"id" => id, "to" => to}) do
    RSS.Repo.toggle_podcast(id)
    redirect(conn, to: Routes.post_path(conn, get_path(to)))
  end

  defp get_path(to) do
    case to do
      "saved" -> :saved
      "podcasts" -> :podcasts
      _ -> :index
    end
  end

  def all_read(conn, _params) do
    Repo.update_all(Post, set: [read: true])
    redirect(conn, to: Routes.post_path(conn, :index))
  end
end
