defmodule RssSync.Sync do
  use GenServer
  alias RssSync.Storage

  @doc """
  Starts the Sync server. Should only be called from a Supervisor.
  """
  def start_link, do: GenServer.start_link(__MODULE__, System.os_time, name: __MODULE__)

  @doc """
  Ensures that the state of the Storage server corresponds to all its
  stored remotes, then asks the Storage server to persist its data.
  Returns `:ok`.
  """
  def sync, do: GenServer.call(__MODULE__, :sync)

  @doc """
  Takes an RSS `feed_url` and saves it to the Storage server.
  Returns `{:ok, feed_url}`.

  This function is basically a convenience wrapper around `Storage.put`,
  removing the need for manually adding `meta` and `entries` when saving.
  """
  def add(feed_url), do: GenServer.call(__MODULE__, {:add, feed_url})

  @doc """
  Takes a `feed_url`, deletes it from the Storage server, and returns `:ok`
  """
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
