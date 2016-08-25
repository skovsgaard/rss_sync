defmodule RssSync.Feed.Meta do
  @type t :: %__MODULE__{}

  defstruct author: nil,
            id: nil,
            image: nil,
            language: nil,
            link: nil,
            subtitle: nil,
            summary: nil,
            title: nil,
            updated: nil

  @spec build_meta(tuple()) :: t()
  def build_meta({:feed, author, id, image, language, link, subtitle, summary, title, updated}) do
    __struct__(author: author, id: id, image: image,
               language: language, link: link, subtitle: subtitle,
               summary: summary, title: title, updated: updated)
  end
end
