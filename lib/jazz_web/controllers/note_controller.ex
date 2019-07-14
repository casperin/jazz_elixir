defmodule JazzWeb.NoteController do
  use JazzWeb, :controller

  @notes_path System.get_env("NOTES_PATH") || "/home/g/notes-x"

  defp full_path(file), do: "#{@notes_path}/#{file}"

  def index(conn, _params) do
    root_trim = String.length(@notes_path) + 1
    render(
      conn,
      "index.html",
      files: Notes.FlatFiles.list_all(@notes_path)
      |> Enum.map(&String.slice(&1, root_trim, 1000)),
      page: "notes"
    )
  end

  def view(conn, %{"file" => file}) do
    render(
      conn,
      "view.html",
      file: file,
      content: File.read!(full_path(file)),
      page: file
    )
  end

  def edit(conn, %{"file" => file}) do
    render(
      conn,
      "edit.html",
      file: file,
      content: File.read!(full_path(file)),
      page: "Edit: ${file}"
    )
  end

  def save(conn, %{"file" => file, "content" => content}) do
    path = full_path(file)
    content = String.replace(content, "\r", "")
    case File.write(path, content) do
      :ok -> 
        conn
        |> put_flash(:info, "Changed saved")
        |> redirect(to: Routes.note_path(conn, :view, file: file))
      {:error, _} ->
        conn
        |> put_flash(:error, "Something went wrong :(")
        |> redirect(to: Routes.note_path(conn, :edit, file: file))
    end
  end

  def git_diff(conn, _params) do
    {status, 0} = System.cmd("git", ["status"], cd: @notes_path)
    {diff, 0} = System.cmd("git", ["diff"], cd: @notes_path)
    render(
      conn,
      "git_diff.html",
      status: status,
      diff: diff,
      page: "Git diff"
    )
  end

  def git_add_commit(conn, %{"message" => message}) do
    System.cmd("git", ["add", "."], cd: @notes_path)
    System.cmd("git", ["commit", "-am", message], cd: @notes_path)
    conn
    |> put_flash(:info, "Committed with #{message}")
    |> redirect(to: Routes.note_path(conn, :git_diff))
  end

  def git_pull(conn, _params) do
    {_, 0} = System.cmd("git", ["pull"], cd: @notes_path)
    conn
    |> put_flash(:info, "git pulled")
    |> redirect(to: Routes.note_path(conn, :git_diff))
  end

  def git_push(conn, _params) do
    {_, 0} = System.cmd("git", ["push"], cd: @notes_path)
    conn
    |> put_flash(:info, "git pushed")
    |> redirect(to: Routes.note_path(conn, :git_diff))
  end
end
