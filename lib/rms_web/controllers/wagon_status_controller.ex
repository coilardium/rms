defmodule RmsWeb.WagonStatusController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.Status
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
       [module_callback: &RmsWeb.WagonStatusController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    tbl_status = SystemUtilities.list_tbl_status()
    render(conn, "index.html", tbl_status: tbl_status)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "wagon status created successfully")
        |> redirect(to: Routes.wagon_status_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.wagon_status_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"rec_status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Status.changeset(%Status{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New wagon status created  with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    status = SystemUtilities.get_status!(id)
    user = conn.assigns.user

    handle_update(user, status, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Wagon status updated successful")
        |> redirect(to: Routes.wagon_status_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.wagon_status_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    status = SystemUtilities.get_status!(id)
    user = conn.assigns.user

    handle_update(user, status, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, status, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Status.changeset(status, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Wagon status with code \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_status!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "wagon status deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(commodity, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, commodity)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted wagon status with code \"#{del.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(new create)a -> {:wagon_status, :create}
      act when act in ~w(index)a -> {:wagon_status, :index}
      act when act in ~w(update edit)a -> {:wagon_status, :edit}
      act when act in ~w(change_status)a -> {:wagon_status, :change_status}
      act when act in ~w(delete)a -> {:wagon_status, :delete}
      _ -> {:wagon_status, :unknown}
    end
  end
end
