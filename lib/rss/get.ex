defmodule RSS do
  @content_left ~r/^(.*?)<content:encoded><!\[CDATA\[/
  @content_right ~r/]]><\/content\:encoded>/

  def get(url) do
    case fetch_(url) do
      {:ok, feed, contents} -> parse(url, feed, contents)
      _ -> {:error, "Could not fetch or parse feed"}
    end
  end

  defp fetch_(url) do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
         {:ok, feed, _header} <- FeederEx.parse(body),
         contents <- find_content(body),
         do: {:ok, feed, contents}
  end

  defp parse(url, feed, contents) do
    entries = if length(feed.entries) == length(contents) do
      feed.entries
      |> Stream.zip(contents)
      |> Enum.map(fn {entry, content} -> Map.put(entry, :summary, content) end)
    else
      feed.entries
    end

    case parse_posts(feed.title, entries) do
      {:ok, posts} ->
        {:ok, %{title: feed.title, url: url}, posts}
      _ ->
        {:error, "Could not parse posts"}
    end
  end

  defp parse_posts(feed_title, entries) do
    {
      :ok,
      entries
      |> Stream.map(fn e -> parse_post(feed_title, e) end)
      |> Enum.filter(fn e ->
        case e do
          :error -> false
          _ -> true
        end
      end)
    }
  end

  defp parse_post(feed_title, entry) do
    %{
      guid: entry.id || guid_from_title(entry.title),
      feed_title: feed_title,
      title: entry.title,
      link: entry.link,
      content: entry.summary
    }
  end

  defp guid_from_title(title) do
    title
    |> Base.encode16(case: :lower)
    |> String.slice(0, 20)
  end

  defp find_content(text) do
    text = String.replace(text, "\n", " ")
    process_content(text, [], :to_left)
  end

  defp process_content(text, contents, :to_left) do
    # We remove until @content_left
    text = String.replace(text, @content_left, "")
    process_content(text, contents, :to_right)
  end

  defp process_content(text, contents, :to_right) do
    case String.split(text, @content_right, parts: 2) do
      [_rest] -> contents # done
      [content, text] ->
        contents = [String.trim(content) | contents]
        process_content(text, contents, :to_left)
    end
  end
end
