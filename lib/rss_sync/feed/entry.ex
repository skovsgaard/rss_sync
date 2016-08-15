defmodule RssSync.Feed.Entry do
  import RssSync.Feed.Enclosure, only: [build_enclosure: 1]

  defstruct author: nil,
            duration: nil,
            enclosure: %{url: nil, length: nil, type: nil},
            id: nil,
            image: nil,
            link: nil,
            subtitle: nil,
            summary: nil,
            title: nil,
            updated: nil

  def build_entry({:entry, author, duration,
                   enclosure, id, image, link,
                   subtitle, summary, title, updated}) do
    __struct__(author: author, duration: duration,
               enclosure: build_enclosure(enclosure),
               id: id, image: image, link: link,
               subtitle: subtitle, summary: summary,
               title: title, updated: updated)
  end
end
