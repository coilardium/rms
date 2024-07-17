defmodule RmsWeb.TransportTypeController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.TransportType
  alias Rms.{Repo, Activity.UserLog}
  alias Rms.SystemUtilities

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.TransportTypeController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    transport_type = SystemUtilities.list_tbl_transport_type()
    render(conn, "index.html", transport_type: transport_type)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Transport type created successfully")
        |> redirect(to: Routes.transport_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.transport_type_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, TransportType.changeset(%TransportType{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Transport type created  with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    transport_type = SystemUtilities.get_transport_type!(id)
    user = conn.assigns.user

    handle_update(user, transport_type, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Transport type updated successful")
        |> redirect(to: Routes.transport_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.transport_type_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    transport_type = SystemUtilities.get_transport_type!(id)
    user = conn.assigns.user

    handle_update(user, transport_type, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, transport_type, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, TransportType.changeset(transport_type, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Transport type with code \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_transport_type!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Transport type deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(transport_type, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, transport_type)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Transport type  with code \"#{del.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def search_transport_type(conn, %{"search" => search_term, "page" => start}) do
    results = SystemUtilities.search_tranport_type("%#{search_term}%", String.to_integer(start))
    total_count = if(length(results) > 0, do: List.first(results).total_count, else: 0)

    json(conn, %{
      results: Enum.map(results, &Map.delete(&1, :total_count)),
      total_count: total_count
    })
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(new create)a -> {:transport_type, :create}
      act when act in ~w(index search_transport_type)a -> {:transport_type, :index}
      act when act in ~w(update edit)a -> {:transport_type, :edit}
      act when act in ~w(change_status)a -> {:transport_type, :change_status}
      act when act in ~w(delete)a -> {:transport_type, :delete}
      _ -> {:transport_type, :unknown}
    end
  end
end
