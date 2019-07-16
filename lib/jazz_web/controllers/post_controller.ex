defmodule JazzWeb.PostController do
  use JazzWeb, :controller

  def index(conn, _params) do
    posts = DB.Get.all_unread_posts
    ids = Stream.map(posts, fn p -> p.id end) |> Enum.join(",")
    render(
      conn,
      "index.html",
      posts: posts,
      ids: ids,
      page: "unread"
    )
  end

  def saved(conn, _params) do
    render(
      conn,
      "saved.html",
      posts: DB.Get.all_saved_posts,
      page: "saved"
    )
  end

  def podcasts(conn, _params) do
    render(
      conn,
      "podcasts.html",
      posts: DB.Get.all_saved_podcasts,
      page: "podcasts"
    )
  end

  def show(conn, %{"id" => id}) do
    post = DB.Get.post(id)
    render(
      conn,
      "show.html",
      post: post,
      page: post.title
    )
  end

  def set_read(conn, %{"id" => id}) do
    DB.Update.set_read_post(id, true)
    redirect(conn, to: Routes.post_path(conn, :index))
  end

  def toggle_saved(conn, %{"id" => id, "to" => to}) do
    DB.Update.toggle_saved_post(id)
    redirect(conn, to: Routes.post_path(conn, get_path(to)))
  end

  def toggle_podcast(conn, %{"id" => id, "to" => to}) do
    DB.Update.toggle_podcast_post(id)
    redirect(conn, to: Routes.post_path(conn, get_path(to)))
  end

  defp get_path("saved"), do: :saved
  defp get_path("podcasts"), do: :podcasts
  defp get_path(_), do: :index

  def all_read(conn, %{"ids" => ids}) do
    if ids != "" do
      DB.Update.set_all_read_post String.split(ids, ","), true
    end
    redirect(conn, to: Routes.post_path(conn, :index))
  end
end
