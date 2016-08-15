defmodule RssSync do
  use Application
  alias RssSync.{Sync, Storage}

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: RssSync.Worker.start_link(arg1, arg2, arg3)
      # worker(RssSync.Worker, [arg1, arg2, arg3]),
      worker(Sync, [], [id: :sync]),
      worker(Storage, [], [id: :storage])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RssSync.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
