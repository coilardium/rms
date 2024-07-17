defmodule RmsWeb.RefuelingTypeController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.Refueling
  alias Rms.{Repo, Activity.UserLog}

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.RefuelingTypeController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    refuel_type = SystemUtilities.list_tbl_refueling_type()
    render(conn, "index.html", refuel_type: refuel_type)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Refuel type created successfully")
        |> redirect(to: Routes.refueling_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.refueling_type_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Refueling.changeset(%Refueling{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "Created refueling type  \"#{create.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    refuel = SystemUtilities.get_refueling!(id)
    user = conn.assigns.user

    handle_update(user, refuel, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Refuel Type updated successful")
        |> redirect(to: Routes.refueling_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.refueling_type_path(conn, :index))
    end
  end

  defp handle_update(user, refuel, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Refueling.changeset(refuel, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Refuel Type \"#{update.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def change_status(conn, %{"id" => id} = params) do
    refuel = SystemUtilities.get_refueling!(id)
    user = conn.assigns.user

    handle_update(user, refuel, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_refueling!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Refuel type deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(refuel, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, refuel)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted refuel type for  \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:refueling_type, :create}
      act when act in ~w(index)a -> {:refueling_type, :index}
      act when act in ~w(update edit)a -> {:refueling_type, :edit}
      act when act in ~w(change_status)a -> {:refueling_type, :change_status}
      act when act in ~w(delete)a -> {:refueling_type, :delete}
      _ -> {:refueling_type, :unknown}
    end
  end
end
