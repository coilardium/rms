defmodule RmsWeb.LocomotiveTypeController do
  use RmsWeb, :controller

  alias Rms.Locomotives
  alias Rms.Locomotives.LocomotiveType
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
       [module_callback: &RmsWeb.LocomotiveTypeController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    locomotive_type = Locomotives.list_tbl_locomotive_type()
    render(conn, "index.html", locomotive_type: locomotive_type)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{type: _type, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Locomotive type Created successfully")
        |> redirect(to: Routes.locomotive_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.locomotive_type_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"maker_id" => user.id, "status" => "D"})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:type, LocomotiveType.changeset(%LocomotiveType{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{type: type} ->
      activity = "Created new locomotive type with \"#{type.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    loco_type = Locomotives.get_locomotive_type!(id)
    user = conn.assigns.user

    handle_update(user, loco_type, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Locomotive type updated successful")
        |> redirect(to: Routes.locomotive_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.locomotive_type_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    loco_type = Locomotives.get_locomotive_type!(id)
    user = conn.assigns.user

    handle_update(user, loco_type, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, loco_type, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, LocomotiveType.changeset(loco_type, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated locomotive type with \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    Locomotives.get_locomotive_type!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Locomotive type deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(loco_type, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, loco_type)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted locomotive type with \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:locomotive_type, :create}
      act when act in ~w(index)a -> {:locomotive_type, :index}
      act when act in ~w(update edit)a -> {:locomotive_type, :edit}
      act when act in ~w(change_status)a -> {:locomotive_type, :change_status}
      act when act in ~w(delete)a -> {:locomotive_type, :delete}
      _ -> {:locomotive_type, :unknown}
    end
  end
end
