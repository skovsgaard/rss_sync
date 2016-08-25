defmodule RssSync.Feed.Enclosure do
  @type t :: %__MODULE__{}

  defstruct url: nil,
            length: nil,
            type: nil

  @spec build_enclosure(tuple()) :: t()
  def build_enclosure({:enclosure, url, length, type}),
    do: __struct__(url: url, length: length, type: type)
end
