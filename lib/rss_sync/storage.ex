defmodule RssSync.Storage do
  @storage_location Application.get_env(:rss_sync, :storage_location)

  @doc """
  Starts the Storage Agent. This should only be called from a Supervisor.
  """
  def start_link do
    Agent.start_link(&load_from_disk/0, name: __MODULE__)
  end

  @doc """
  Returns all feeds currently stored on the Agent.
  """
  def all, do: Agent.get(__MODULE__, fn state -> state end)

  @doc """
  Takes a pair `{rss_feed_url, {meta, entries}}` stores it on the Agent,
  and returns `:ok`.
  """
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
  def del(feed_url) do
    Agent.update(__MODULE__, fn state ->
      Enum.reject(state, fn {url, _pair} -> url == feed_url end)
    end)
  end

  @doc """
  Takes an arbitrary term, searches for it in the metadata of each feed and
  returns the first matching feed in the format `{url, {meta, entries}}`.
  """
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
    :dets.insert(dets_name, all)
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
