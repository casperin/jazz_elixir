defmodule RSS do
  def get(url) do
    IO.puts "get URL #{url}"
    case fetch_(url) do
      {:ok, feed} -> parse(url, feed)
      _ -> {:error, "Could not fetch or parse feed"}
    end
  end

  defp fetch_(url) do
    IO.puts "URL #{url}"
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
         {:ok, feed, _header} <- FeederEx.parse(body),
         do: {:ok, feed}
  end

  defp parse(url, feed) do
    case parse_posts(feed.title, feed.entries) do
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
end
