defmodule RmsWeb.CommodityGroupController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.CommodityGroup
  alias Rms.Logs.UserLog
  alias Rms.SystemUtilities
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
       [module_callback: &RmsWeb.CommodityGroupController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    commodity_group = SystemUtilities.list_tbl_commodity_group()
    render(conn, "index.html", commodity_group: commodity_group)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Commodity group created successfully")
        |> redirect(to: Routes.commodity_group_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.commodity_group_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, CommodityGroup.changeset(%CommodityGroup{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Commodity group created with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    commodity = SystemUtilities.get_commodity_group!(id)
    user = conn.assigns.user

    handle_update(user, commodity, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Commodity group updated successful")
        |> redirect(to: Routes.commodity_group_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.commodity_group_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    commodity = SystemUtilities.get_commodity_group!(id)
    user = conn.assigns.user

    handle_update(user, commodity, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, commodity, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, CommodityGroup.changeset(commodity, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated commodity group code with \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_commodity_group!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "commodity group deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(commodity, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, commodity)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted commodity group code with \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:commodity_group, :create}
      act when act in ~w(index)a -> {:commodity_group, :index}
      act when act in ~w(update edit)a -> {:commodity_group, :edit}
      act when act in ~w(change_status)a -> {:commodity_group, :change_status}
      act when act in ~w(delete)a -> {:commodity_group, :delete}
      _ -> {:commodity_group, :unknown}
    end
  end
end
