defmodule SimpleProyect.Application do
  use Application

  def start(_type, _args) do
    children = [
      SimpleProyect.Repo,
      {Plug.Cowboy, scheme: :http, plug: SimpleProyect.Router, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: SimpleProyect.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
