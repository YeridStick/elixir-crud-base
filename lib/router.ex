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
