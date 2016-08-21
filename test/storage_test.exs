defmodule RssSynctest.Storage do
  use ExUnit.Case, async: true
  alias RssSync.{Storage, Feed}
  
  @test_url "https://fupifarvandet.dk/episodes.rss"
  @test_meta_value "Fup I Farvandet"

  setup do
    {:ok, %{body: rss}} = HTTPoison.get(@test_url)
    feed_pair = Feed.parse(rss)
    {:ok, %{rss: rss, feed_pair: feed_pair}}
  end

  test "feeds can be stored", %{feed_pair: pair} do
    assert :ok = Storage.put {@test_url, pair}
  end

  test "feeds can be found when stored on the Agent", %{feed_pair: pair} do
    :ok = Storage.put {@test_url, pair}
    assert {@test_url, ^pair} = Storage.find @test_meta_value
  end

  test "when stored, a full list of feeds can be retrieved", %{feed_pair: pair} do
    for _ <- 1..2, do: Storage.put {@test_url, pair}
    assert [{@test_url, ^pair} | _rest] = Storage.all
    assert Enum.count(Storage.all) == 1
  end
end
