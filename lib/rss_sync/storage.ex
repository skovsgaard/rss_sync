defmodule RssSync.Storage do
  @storage_location Application.get_env(:rss_sync, :storage_location)

  @type url :: String.t
  @type entry :: %RssSync.Feed.Entry{}
  @type meta :: %RssSync.Feed.Meta{}

  @doc """
  Starts the Storage Agent. This should only be called from a Supervisor.
  """
  @spec start_link() :: {:error, term()} | {:ok, pid()}
  def start_link do
    Agent.start_link(&load_from_disk/0, name: __MODULE__)
  end

  @doc """
  Returns all feeds currently stored on the Agent.
  """
  @spec all() :: [{url(), {meta(), entry()}}] | []
  def all, do: Agent.get(__MODULE__, fn state -> state end)

  @doc """
  Takes a pair `{rss_feed_url, {meta, entries}}` stores it on the Agent,
  and returns `:ok`.
  """
  @spec put({url(), {meta(), [entry()]}}) :: :ok
  def put(feed_pair) do
    Agent.update(__MODULE__, fn state ->
      unless feed_pair in state do
        [feed_pair|state] |> Enum.reverse
      else
        state
      end
    end)
  end

  @doc """
  Takes an RSS feed URL and deletes the corresponding feed on the Agent.
  Returns `:ok`.
  """
  @spec del(url()) :: :ok
  def del(feed_url) do
    Agent.update(__MODULE__, fn state ->
      Enum.reject(state, fn {url, _pair} -> url == feed_url end)
    end)
  end

  @doc """
  Takes an arbitrary term, searches for it in the metadata of each feed and
  returns the first matching feed in the format `{url, {meta, entries}}`.
  """
  @spec find(any()) :: {url(), {meta(), [entry()]}} | atom()
  def find(meta_value) do
    Agent.get(__MODULE__, fn state ->
      Enum.find(state, fn {url, {meta, _entries}} ->
        meta_value in Map.values(meta) or meta_value == url
      end)
    end)
  end

  @doc """
  Takes no argument, stores the current state of the Storage Agent on disk,
  and returns `:ok`.
  """
  def persist do
    {:ok, dets_name} =
      :dets.open_file(:rss_sync, file: String.to_char_list(@storage_location))
    :ok = :dets.insert(dets_name, all)
    :ok = :dets.close(dets_name)
  end

  defp load_from_disk do
    {:ok, dets_name} =
      :dets.open_file :rss_sync, file: String.to_char_list(@storage_location)
    previous_stored =
      :dets.foldl(fn x, acc -> [x|acc] end, [], dets_name) |> Enum.reverse
    :ok = :dets.close(dets_name)

    previous_stored
  end
end
