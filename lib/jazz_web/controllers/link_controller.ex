defmodule JazzWeb.LinkController do
  use JazzWeb, :controller

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      links: DB.Get.all_links,
      page: "links"
    )
  end

  def create(conn, %{"url" => url}) do
    DB.Update.insert_link url, get_title_from_url(url)
    render(
      conn,
      "index.html",
      links: DB.Get.all_links,
      page: "links"
    )
  end

  def delete(conn, %{"id" => id}) do
    case DB.Update.delete_link(id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "The link will miss you")
        |> redirect(to: Routes.link_path(conn, :index))
      _ ->
        conn
        |> put_flash(:error, "Couldn't delete from the link :(")
        |> render("show.html", id: id)
    end
  end

  ###
  # Below two functions do not belong here, but nowhere good to put them for now
  ###
  defp get_title_from_url(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body}} -> get_title_from_body(body, url)
      _ -> url
    end
  end

  defp get_title_from_body(body, url) do
    case String.split(body, ["<title>", "</title>"]) do
      [_, title, _] -> title
      _ -> url
    end
  end
end
