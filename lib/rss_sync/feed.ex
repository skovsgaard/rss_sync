defmodule RssSync.Feed do
  import RssSync.Feed.Meta, only: [build_meta: 1]
  import RssSync.Feed.Entry, only: [build_entry: 1]

  def parse(rss_feed) do
    {:ok, {meta, entries}, _} = :feeder.stream(rss_feed, [])
    {build_meta(meta), Enum.map(entries, &build_entry/1)}
  end
end
