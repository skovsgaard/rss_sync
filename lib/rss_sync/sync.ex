defmodule RssSync.Sync do
  use GenServer
  alias RssSync.Storage

  @type url() :: String.t

  @doc """
  Starts the Sync server. Should only be called from a Supervisor.
  """
  @spec start_link() :: {:ok, pid()} | {:error, term()}
  def start_link, do: GenServer.start_link(__MODULE__, System.os_time, name: __MODULE__)

  @doc """
  Ensures that the state of the Storage server corresponds to all its
  stored remotes, then asks the Storage server to persist its data.
  Returns `:ok`.
  """
  @spec sync() :: :ok
  def sync, do: GenServer.call(__MODULE__, :sync)

  @doc """
  Takes an RSS `feed_url` and saves it to the Storage server.
  Returns `{:ok, feed_url}`.

  This function is basically a convenience wrapper around `Storage.put`,
  removing the need for manually adding `meta` and `entries` when saving.
  """
  @spec add(url) :: {:ok, url()}
  def add(feed_url), do: GenServer.call(__MODULE__, {:add, feed_url})

  @doc """
  Takes a `feed_url`, deletes it from the Storage server, and returns `:ok`
  """
  @spec delete(url()) :: :ok
  def delete(feed_url), do: GenServer.call(__MODULE__, {:del, feed_url})

  def handle_call(:sync, _from, _last_sync_time) do
    [_h|_t] = synchronize_feeds
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
    for {url, _feed_pair} <- Storage.all, do: save_from_url(url)
  end

  defp save_from_url(url) do
    {:ok, %{body: fresh_rss}} = HTTPoison.get(url)
    Storage.put({url, RssSync.Feed.parse(fresh_rss)})
  end
end
