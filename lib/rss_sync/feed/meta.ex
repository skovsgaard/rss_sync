defmodule RssSync.Feed.Meta do
  defstruct author: nil,
            id: nil,
            image: nil,
            language: nil,
            link: nil,
            subtitle: nil,
            summary: nil,
            title: nil,
            updated: nil

  def build_meta({:feed, author, id, image, language, link, subtitle, summary, title, updated}) do
    __struct__(author: author, id: id, image: image,
               language: language, link: link, subtitle: subtitle,
               summary: summary, title: title, updated: updated)
  end
end
