defmodule RmsWeb.UserRegionController do
  use RmsWeb, :controller

  alias Rms.Accounts
  alias Rms.Accounts.UserRegion
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
       [module_callback: &RmsWeb.UserRegionController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    stations = Rms.SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    regions = Accounts.list_tbl_user_region()
    render(conn, "index.html", regions: regions, stations: stations)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "user region created successfully")
        |> redirect(to: Routes.user_region_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.user_region_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, UserRegion.changeset(%UserRegion{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New User region created with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    region = Accounts.get_user_region!(id)
    user = conn.assigns.user

    handle_update(user, region, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "User region updated successful")
        |> redirect(to: Routes.user_region_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.user_region_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    region = Accounts.get_user_region!(id)
    user = conn.assigns.user

    handle_update(user, region, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, region, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, UserRegion.changeset(region, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated User region with code \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    Accounts.get_user_region!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "User region deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(region, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, region)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted  user region  with code \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:user_region, :create}
      act when act in ~w(index)a -> {:user_region, :index}
      act when act in ~w(update edit)a -> {:user_region, :edit}
      act when act in ~w(change_status)a -> {:user_region, :change_status}
      act when act in ~w(delete)a -> {:user_region, :delete}
      _ -> {:user_region, :unknown}
    end
  end
end
