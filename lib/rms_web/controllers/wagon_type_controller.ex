defmodule RmsWeb.WagonTypeController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.WagonType
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
       [module_callback: &RmsWeb.WagonTypeController.authorize/1]
       when action not in [:unknown]

  def index(conn, %{"type" => type}) do
    wagon_type = SystemUtilities.list_tbl_wagon_type() |> Enum.reject(&(&1.category != String.upcase(type)))
    render(conn, "index.html", wagon_type: wagon_type, type: type)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Wagon type created successfully")
        |> redirect(to: Routes.wagon_type_path(conn, :index, String.capitalize(params["category"])))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.wagon_type_path(conn, :index, String.capitalize(params["category"])))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, WagonType.changeset(%WagonType{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Wagon type created with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    wagon = SystemUtilities.get_wagon_type!(id)
    user = conn.assigns.user

    handle_update(user, wagon, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "wagon type updated successful")
        |> redirect(to: Routes.wagon_type_path(conn, :index, String.capitalize(params["category"])))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.wagon_type_path(conn, :index, String.capitalize(params["category"])))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    wagon = SystemUtilities.get_wagon_type!(id)
    user = conn.assigns.user

    handle_update(user, wagon, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, wagon, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, WagonType.changeset(wagon, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Wagon type code with \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_wagon_type!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Wagon deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(commodity, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, commodity)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Wagon code with \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:wagon_type, :create}
      act when act in ~w(index)a -> {:wagon_type, :index}
      act when act in ~w(update edit)a -> {:wagon_type, :edit}
      act when act in ~w(change_status)a -> {:wagon_type, :change_status}
      act when act in ~w(delete)a -> {:wagon_type, :delete}
      _ -> {:wagon_type, :unknown}
    end
  end
end
