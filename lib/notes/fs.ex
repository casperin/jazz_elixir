defmodule FS do 
  def list_files(filepath) do
    _list_files(filepath)
  end

  defp _list_files(filepath) do 
    cond do
      String.contains?(filepath, ".git") -> [] # ignore .git
      true -> expand(File.ls(filepath), filepath)       
    end
  end

  defp expand({:ok, files}, path) do
    files
    |> Enum.flat_map(&_list_files("#{path}/#{&1}"))
  end

  defp expand({:error, _}, path) do 
    if String.contains?(path, [".md", ".js", ".json"]) do
      [path]
    else
      []
    end
  end

  def list_dirs(filepath) do
    _list_dirs(filepath)
  end

  defp _list_dirs(filepath) do
    cond do
      String.contains?(filepath, ".git") -> [] # ignore .git
      true -> expand_dir(File.ls(filepath), filepath)       
    end
  end

  defp expand_dir({:ok, files}, path) do
    ["#{path}/" | Enum.flat_map(files, &_list_dirs("#{path}/#{&1}"))]
  end

  defp expand_dir({:error, _}, _path), do: []
end
