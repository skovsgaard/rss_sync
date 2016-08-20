use Mix.Config

config :rss_sync,
  storage_location: Path.join([
    System.user_home,
    ".rss_sync",
    "/",
    "rss_sync.dat"
  ])
