defmodule RssSync.Storage do
  @storage_location Application.get_env(:rss_sync, :storage_location)

  def start_link do
    Agent.start_link(&load_from_disk/0, name: __MODULE__)
  end

  def all, do: Agent.get(__MODULE__, fn state -> state end)

  def put(feed_pair) do
    Agent.update(__MODULE__, fn state ->
      [feed_pair|state] |> Enum.reverse
    end)
  end

  def del(feed_url) do
    Agent.update(__MODULE__, fn state ->
      Enum.reject(state, fn {url, _pair} -> url == feed_url end)
    end)
  end

  def find(meta_value) do
    Agent.get(__MODULE__, fn state ->
      Enum.find(state, fn {url, {meta, _entries}} ->
        meta_value in Map.values(meta) or meta_value == url
      end)
    end)
  end

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
