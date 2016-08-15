defmodule RssSync.Sync do
  use GenServer
  alias RssSync.Storage

  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

end
