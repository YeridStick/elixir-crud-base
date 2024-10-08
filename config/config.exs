import Config

config :simple_proyect, ecto_repos: [SimpleProyect.Repo]

config :simple_proyect, SimpleProyect.Repo,
  database: "elixir-ejemplo",
  username: "elixir",
  password: "elixir",
  hostname: "localhost"
