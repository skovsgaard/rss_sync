defmodule RssSync.Feed.Enclosure do
  defstruct url: nil,
            length: nil,
            type: nil

  def build_enclosure({:enclosure, url, length, type}),
    do: __struct__(url: url, length: length, type: type)
end
