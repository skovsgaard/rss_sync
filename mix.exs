defmodule RssSync.Mixfile do
  use Mix.Project

  def project do
    [app: :rss_sync,
     version: "0.2.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: "An OTP application to keep RSS feeds in sync with the real world.",
     package: [
       licenses: ["MPL 2.0"],
       maintainers: ["Jonas Skovsgaard Christensen"],
       links: %{"Github" => "https://github.com/skovsgaard/rss_sync"}
     ],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison],
     mod: {RssSync, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:feeder, git: "https://github.com/michaelnisi/feeder"},
     {:httpoison, "~> 0.9"},
     {:ex_doc, "~> 0.13", only: :dev},
     {:dialyxir, "~> 0.3.5"}]
  end
end
