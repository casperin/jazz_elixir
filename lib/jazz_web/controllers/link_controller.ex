defmodule JazzWeb.LinkController do
  use JazzWeb, :controller
  alias Jazz.{Repo, Link}

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      links: Repo.all(Link),
      page: "links"
    )
  end

  def create(conn, %{"url" => url}) do
    title = get_title_from_url(url)
    link = Link.changeset(%Link{}, %{ url: url, title: title})
    Repo.insert!(link)
    render(
      conn,
      "index.html",
      links: Repo.all(Link),
      page: "links"
    )
  end

  def delete(conn, %{"id" => id}) do
    link = Repo.get!(Link, id)
    case Repo.delete link do
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
