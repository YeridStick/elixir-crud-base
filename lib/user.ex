defmodule SimpleProyect.User do
  use Ecto.Schema
  import Ecto.Changeset
  @derive {Jason.Encoder, only: [:id, :name, :email, :age, :inserted_at, :updated_at]}

  schema "users" do
    field :name, :string
    field :email, :string
    field :age, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :age])
    |> validate_required([:name, :email, :age])
  end
end
