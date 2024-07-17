defmodule RmsWeb.LocoDriverController do
  use RmsWeb, :controller

  alias Rms.Accounts.LocoDriver
  alias Rms.{Repo, Activity.UserLog, Accounts}

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.LocoDriverController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    loco_driver = Accounts.list_tbl_loco_driver()
    render(conn, "index.html", loco_driver: loco_driver)
  end

  def change_status(conn, %{"id" => id} = params) do
    loco_driver = Accounts.get_loco_driver!(id)
    user = conn.assigns.user

    handle_update(user, loco_driver, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, loco_driver, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, LocoDriver.changeset(loco_driver, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: _update} ->
      activity = "Updated locomotive driver with id \"#{loco_driver.id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    Accounts.get_loco_driver!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{loco_driver: _loco_driver, user_log: _user_log}} ->
        conn |> json(%{"info" => "loco_driver deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(loco_driver, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:loco_driver, loco_driver)
    |> Ecto.Multi.run(:user_log, fn repo, %{loco_driver: loco_driver} ->
      activity = "Deleted loco driver \"#{loco_driver.id}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{add_logo_driver: _add_client, user_log: _user_log}} ->
        conn
        |> json(%{message: "Assigned As Loco Driver Successfully", status: 0})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{message: reason, status: 1})
    end
  end

  defp handle_create(user, %{"id" => id} = params) do
    user_details = Accounts.get_user!(id)

    params =
      Map.merge(params, %{"status" => "D", "user_id" => user_details.id, "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:add_logo_driver, LocoDriver.changeset(%LocoDriver{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{add_logo_driver: _add_logo_driver} ->
      activity = "Assigned As Loco Driver Successfully"

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
      act when act in ~w(new create)a -> {:loco_driver, :create}
      act when act in ~w(index)a -> {:loco_driver, :index}
      act when act in ~w(update edit)a -> {:loco_driver, :edit}
      act when act in ~w(change_status)a -> {:loco_driver, :change_status}
      act when act in ~w(delete)a -> {:loco_driver, :delete}
      _ -> {:loco_driver, :unknown}
    end
  end
end
