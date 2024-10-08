defmodule SimpleProyect.Repo do
  use Ecto.Repo,
    otp_app: :simple_proyect,
    adapter: Ecto.Adapters.Postgres
end
