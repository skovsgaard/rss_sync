use Mix.Config

dirname = "#{System.cwd}/tmp"
File.mkdir_p dirname

config :rss_sync,
  storage_location: "#{dirname}/rss_sync.dat"
