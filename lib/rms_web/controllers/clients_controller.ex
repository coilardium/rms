defmodule RmsWeb.ClientsController do
  use RmsWeb, :controller

  alias Rms.Accounts.Clients
  alias Rms.{Repo, Activity.UserLog}
  alias Rms.Accounts

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.ClientsController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    clients = Accounts.list_tbl_clients()
    render(conn, "index.html", clients: clients)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Client created successfully")
        |> redirect(to: Routes.clients_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.clients_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Clients.changeset(%Clients{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Client \"#{create.client_name}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    client = Accounts.get_clients!(id)
    user = conn.assigns.user

    handle_update(user, client, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Client updated successful")
        |> redirect(to: Routes.clients_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.clients_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    client = Accounts.get_clients!(id)
    user = conn.assigns.user

    handle_update(user, client, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, client, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Clients.changeset(client, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated client \"#{update.client_name}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    Accounts.get_clients!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Client deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(client, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, client)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted  client \"#{del.client_name}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def upadte_clients_desc() do
    items = Accounts.list_tbl_clients()

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      client_name = String.capitalize(item.client_name)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:client, index},
        Clients.changeset(item, %{client_name: client_name})
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        %{"info" => "update successfully."}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        %{"error" => reason}
    end
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(new create)a -> {:clients, :create}
      act when act in ~w(index)a -> {:clients, :index}
      act when act in ~w(update edit)a -> {:clients, :edit}
      act when act in ~w(change_status)a -> {:clients, :change_status}
      act when act in ~w(delete)a -> {:clients, :delete}
      _ -> {:clients, :unknown}
    end
  end
end
