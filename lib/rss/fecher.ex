defmodule RSS.Fetcher do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work(10 * 60 * 1000) # In 10 minutes
    {:ok, state}
  end

  def handle_info(:fetch, state) do
    Jazz.Repo.all(Jazz.Feed)
    |> Stream.map(fn feed -> {feed.id, RSS.Get.fetch(feed.url)} end)
    |> Stream.map(fn {feed_id, {:ok, _feed, posts}} -> {posts, feed_id} end)
    |> Enum.each(&RSS.Repo.insert_posts_optimistic(&1))

    schedule_work(60 * 60 * 1000) # In 1 hour
    {:noreply, state}
  end

  defp schedule_work(timeout) do
    Process.send_after(self(), :fetch, timeout)
  end
end
