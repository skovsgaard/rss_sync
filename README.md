# RssSync

This is an OTP application which retrieves, parses, and stores RSS feeds, and when prompted to, keeps them in sync with their RSS feed sources.

Its API isn't finalized but it's usable as is and currently allows for adding, removing, synchronizing, and persisting feeds to disk.

## Installation

[Available on Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `rss_sync` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rss_sync, "~> 0.1.0"}]
    end
    ```

  2. Ensure `rss_sync` is started before your application:

    ```elixir
    def application do
      [applications: [:rss_sync]]
    end
    ```

