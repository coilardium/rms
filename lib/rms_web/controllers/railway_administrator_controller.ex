defmodule RmsWeb.RailwayAdministratorController do
  use RmsWeb, :controller

  alias Rms.Accounts.RailwayAdministrator
  alias Rms.SystemUtilities
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
       [module_callback: &RmsWeb.RailwayAdministratorController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    country = SystemUtilities.list_tbl_country() |> Enum.reject(&(&1.status != "A"))
    railway_administrator = Accounts.list_tbl_railway_administrator()
    render(conn, "index.html", railway_administrator: railway_administrator, country: country)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Railway administrator created successfully")
        |> redirect(to: Routes.railway_administrator_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.railway_administrator_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, RailwayAdministrator.changeset(%RailwayAdministrator{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New  railway administrator created  \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    admin = Accounts.get_railway_administrator!(id)
    user = conn.assigns.user

    handle_update(user, admin, Map.put(params, "maker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Railway administrator updated successful")
        |> redirect(to: Routes.railway_administrator_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.railway_administrator_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    admin = Accounts.get_railway_administrator!(id)
    user = conn.assigns.user

    handle_update(user, admin, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, admin, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, RailwayAdministrator.changeset(admin, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated railway administrator \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    Accounts.get_railway_administrator!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Railway administrator deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(admin, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, admin)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted railway administrator \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:railway_administrator, :create}
      act when act in ~w(index)a -> {:railway_administrator, :index}
      act when act in ~w(update edit)a -> {:railway_administrator, :edit}
      act when act in ~w(change_status)a -> {:railway_administrator, :change_status}
      act when act in ~w(delete)a -> {:railway_administrator, :delete}
      _ -> {:railway_administrator, :unknown}
    end
  end
end
