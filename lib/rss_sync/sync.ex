defmodule RssSync.Sync do
  use GenServer
  alias RssSync.Storage

  def start_link, do: GenServer.start_link(__MODULE__, System.os_time, name: __MODULE__)

  def sync, do: GenServer.call(__MODULE__, :sync)

  def add(feed_url), do: GenServer.call(__MODULE__, {:add, feed_url})

  def delete(feed_url), do: GenServer.call(__MODULE__, {:del, feed_url})

  def handle_call(:sync, _from, _last_sync_time) do
    synchronize_feeds
    spawn_link(&Storage.persist/0)
    {:reply, :ok, System.os_time}
  end

  def handle_call({:add, feed_url}, _from, last_sync_time) do
    save_from_url(feed_url)
    {:reply, {:ok, feed_url}, last_sync_time}
  end

  def handle_call({:del, feed_url}, _from, last_sync_time) do
    Storage.del(feed_url)
    {:reply, :ok, last_sync_time}
  end

  defp synchronize_feeds do
    Enum.each(Storage.all, fn {url, _feed_pair} -> save_from_url(url) end)
  end

  defp save_from_url(url) do
    {:ok, %{body: fresh_rss}} = HTTPoison.get(url)
    Storage.put({url, RssSync.Feed.parse(fresh_rss)})
  end
end
