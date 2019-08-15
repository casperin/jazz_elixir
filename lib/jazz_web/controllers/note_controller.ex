defmodule JazzWeb.NoteController do
  use JazzWeb, :controller

  @notes_path System.get_env("NOTES_PATH") || "/home/g/notes"
  @root_trim String.length(@notes_path) + 1

  defp full_path(file), do: "#{@notes_path}/#{file}"

  def index(conn, _params) do
    render(
      conn,
      "index.html",
      files: FS.list_files(@notes_path)
      |> Enum.map(&String.slice(&1, @root_trim, 1000)),
      page: "notes"
    )
  end

  def new(conn, _params) do
    render(
      conn,
      "new.html",
      dirs: FS.list_dirs(@notes_path)
      |> Enum.map(&String.slice(&1, @root_trim, 1000)),
      page: "Create note"
    )
  end

  def create(conn, %{"path" => path}) do
    :ok = File.touch("#{@notes_path}/#{path}")
    conn
    |> redirect(to: Routes.note_path(conn, :edit, file: path))
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
      page: "Edit: #{file}"
    )
  end

  def save(conn, %{"file" => file, "content" => content}) do
    :ok = File.write full_path(file), String.replace(content, "\r", "")
    conn
    |> put_flash(:info, "Changed saved")
    |> redirect(to: Routes.note_path(conn, :view, file: file))
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
