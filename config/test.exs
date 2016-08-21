use Mix.Config

dirname = System.tmp_dir
File.mkdir_p dirname

config :rss_sync,
  storage_location: "#{dirname}/rss_sync.dat"
