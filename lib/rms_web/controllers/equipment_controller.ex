defmodule RmsWeb.EquipmentController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.Equipment
  alias Rms.Logs.UserLog
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
       [module_callback: &RmsWeb.EquipmentController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    equipments = SystemUtilities.list_tbl_equipments()
    render(conn, "index.html", equipments: equipments)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Equipment created successfully")
        |> redirect(to: Routes.equipment_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.equipment_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Equipment.changeset(%Equipment{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Created equipment \"#{create.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    equipment = SystemUtilities.get_equipment!(id)
    user = conn.assigns.user

    handle_update(user, equipment, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Equipment updated successful")
        |> redirect(to: Routes.equipment_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.equipment_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    equipment = SystemUtilities.get_equipment!(id)
    user = conn.assigns.user

    handle_update(user, equipment, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, equipment, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Equipment.changeset(equipment, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated equipment \"#{update.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_equipment!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Equipment deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(equipment, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, equipment)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted equipment \"#{del.description}\""

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
      act when act in ~w(new create)a -> {:equipment, :create}
      act when act in ~w(index)a -> {:equipment, :index}
      act when act in ~w(update edit)a -> {:equipment, :edit}
      act when act in ~w(change_status)a -> {:equipment, :change_status}
      act when act in ~w(delete)a -> {:equipment, :delete}
      _ -> {:equipment, :unknown}
    end
  end
end
