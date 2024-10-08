Claro, te proporcionaré una guía paso a paso de todo lo que hemos hecho para crear este proyecto de API REST en Elixir. Esta guía será didáctica y directa, ideal para aprender el proceso de creación de APIs REST con Elixir.

Guía para crear una API REST en Elixir desde cero:

1. Crear un nuevo proyecto Elixir:
   ```
   mix new simple_proyect
   cd simple_proyect
   ```

2. Configurar las dependencias en `mix.exs`:
   Abre `mix.exs` y modifica la función `deps` así:
   ```elixir
   defp deps do
     [
       {:postgrex, "~> 0.19.1"},
       {:ecto_sql, "~> 3.12"},
       {:plug_cowboy, "~> 2.7"},
       {:jason, "~> 1.4"}
     ]
   end
   ```

3. Configurar la aplicación en `mix.exs`:
   Modifica la función `application` así:
   ```elixir
   def application do
     [
       extra_applications: [:logger],
       mod: {SimpleProyect.Application, []}
     ]
   end
   ```

4. Instalar dependencias:
   ```
   mix deps.get
   ```

5. Configurar la base de datos:
   Crea un archivo `config/config.exs` con el siguiente contenido:
   ```elixir
   import Config

   config :simple_proyect, ecto_repos: [SimpleProyect.Repo]

   config :simple_proyect, SimpleProyect.Repo,
     database: "elixir-ejemplo",
     username: "elixir",
     password: "elixir",
     hostname: "localhost"
   ```

6. Crear el módulo Repo:
   Crea un archivo `lib/simple_proyect/repo.ex`:
   ```elixir
   defmodule SimpleProyect.Repo do
     use Ecto.Repo,
       otp_app: :simple_proyect,
       adapter: Ecto.Adapters.Postgres
   end
   ```

7. Crear el módulo Application:
   Crea un archivo `lib/simple_proyect/application.ex`:
   ```elixir
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
   ```

8. Crear una migración para la tabla de usuarios:
   ```
   mix ecto.gen.migration create_users
   ```
   Edita el archivo generado en `priv/repo/migrations/`:
   ```elixir
   defmodule SimpleProyect.Repo.Migrations.CreateUsers do
     use Ecto.Migration

     def change do
       create table(:users) do
         add :name, :string
         add :email, :string
         add :age, :integer

         timestamps()
       end

       create unique_index(:users, [:email])
     end
   end
   ```

9. Crear y migrar la base de datos:
   ```
   mix ecto.create
   mix ecto.migrate
   ```

10. Crear el schema User:
    Crea un archivo `lib/simple_proyect/user.ex`:
    ```elixir
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

      def changeset(user, attrs) do
        user
        |> cast(attrs, [:name, :email, :age])
        |> validate_required([:name, :email, :age])
      end
    end
    ```

11. Crear el módulo principal con funciones CRUD:
    Edita `lib/simple_proyect.ex`:
    ```elixir
    defmodule SimpleProyect do
      alias SimpleProyect.{Repo, User}

      def create_user(attrs \\ %{}) do
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()
      end

      def list_users do
        Repo.all(User)
      end

      def get_user(id) do
        Repo.get(User, id)
      end

      def update_user(%User{} = user, attrs) do
        user
        |> User.changeset(attrs)
        |> Repo.update()
      end

      def delete_user(%User{} = user) do
        Repo.delete(user)
      end
    end
    ```

12. Crear el Router:
    Crea un archivo `lib/simple_proyect/router.ex`:
    ```elixir
    defmodule SimpleProyect.Router do
      use Plug.Router

      plug :match
      plug Plug.Parsers,
        parsers: [:json],
        pass: ["application/json"],
        json_decoder: Jason
      plug :dispatch

      get "/users" do
        users = SimpleProyect.list_users()
        send_resp(conn, 200, Jason.encode!(%{users: users}))
      end

      get "/users/:id" do
        case SimpleProyect.get_user(String.to_integer(id)) do
          nil ->
            send_resp(conn, 404, Jason.encode!(%{error: "User not found"}))
          user ->
            send_resp(conn, 200, Jason.encode!(%{user: user}))
        end
      end

      post "/users" do
        case SimpleProyect.create_user(conn.body_params) do
          {:ok, user} ->
            send_resp(conn, 201, Jason.encode!(%{user: user}))
          {:error, changeset} ->
            send_resp(conn, 422, Jason.encode!(%{errors: changeset_errors_to_map(changeset)}))
        end
      end

      put "/users/:id" do
        case SimpleProyect.get_user(String.to_integer(id)) do
          nil ->
            send_resp(conn, 404, Jason.encode!(%{error: "User not found"}))
          user ->
            case SimpleProyect.update_user(user, conn.body_params) do
              {:ok, updated_user} ->
                send_resp(conn, 200, Jason.encode!(%{user: updated_user}))
              {:error, changeset} ->
                send_resp(conn, 422, Jason.encode!(%{errors: changeset_errors_to_map(changeset)}))
            end
        end
      end

      delete "/users/:id" do
        case SimpleProyect.get_user(String.to_integer(id)) do
          nil ->
            send_resp(conn, 404, Jason.encode!(%{error: "User not found"}))
          user ->
            case SimpleProyect.delete_user(user) do
              {:ok, _} ->
                send_resp(conn, 204, "")
              {:error, changeset} ->
                send_resp(conn, 422, Jason.encode!(%{errors: changeset_errors_to_map(changeset)}))
            end
        end
      end

      match _ do
        send_resp(conn, 404, "Not found")
      end

      defp changeset_errors_to_map(changeset) do
        Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)
      end
    end
    ```

13. Iniciar la aplicación:
    ```
    iex -S mix
    ```

Ahora tienes una API REST funcional que puede realizar operaciones CRUD en usuarios. Puedes probar los endpoints con herramientas como cURL o Postman:

- GET http://localhost:4000/users
- POST http://localhost:4000/users (con body JSON)
- GET http://localhost:4000/users/:id
- PUT http://localhost:4000/users/:id (con body JSON)
- DELETE http://localhost:4000/users/:id

Esta guía cubre la creación de un proyecto Elixir básico, la configuración de Ecto para la base de datos, la definición de un schema, la implementación de funciones CRUD, y la creación de un router para manejar solicitudes HTTP. Es un buen punto de partida para entender cómo construir APIs REST con Elixir.
