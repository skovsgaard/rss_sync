defmodule RssSynctest.Sync do
  use ExUnit.Case, async: true
  alias RssSync.{Sync, Feed}

  @test_url "https://feeds.feedburner.com/HarmontownPodcast"

  setup do
    {:ok, %{body: rss}} = HTTPoison.get(@test_url)
    feed_pair = Feed.parse(rss)
    {:ok, @test_url} = Sync.add @test_url
    {:ok, %{feed_pair: feed_pair}}
  end

  test "new feeds can be added via Sync module" do
    assert {:ok, @test_url} = Sync.add @test_url
  end

  test "feeds can be deleted through the sync module" do
    assert :ok = Sync.delete @test_url
  end

  test "feeds can be synchronized" do
    assert :ok = Sync.sync
    assert File.exists?(Application.get_env(:rss_sync, :storage_location))
  end
end
