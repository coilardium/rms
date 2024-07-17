defmodule RmsWeb.WagonConditionController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.Condition
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
       [module_callback: &RmsWeb.WagonConditionController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    condition = SystemUtilities.list_tbl_condition()
    wagon_status = SystemUtilities.list_tbl_status() |> Enum.reject(&(&1.status != "A"))
    cond_cat = SystemUtilities.list_tbl_condition_category() |> Enum.reject(&(&1.status != "A"))

    render(conn, "index.html",
      condition: condition,
      wagon_status: wagon_status,
      cond_cat: cond_cat
    )
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "New wagon condition created successfully")
        |> redirect(to: Routes.wagon_condition_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.wagon_condition_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Condition.changeset(%Condition{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Wagon condition created  with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    condition = SystemUtilities.get_condition!(id)
    user = conn.assigns.user

    handle_update(user, condition, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Wagon condition updated successful")
        |> redirect(to: Routes.wagon_condition_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.wagon_condition_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    condition = SystemUtilities.get_condition!(id)
    user = conn.assigns.user

    handle_update(user, condition, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, condition, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Condition.changeset(condition, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated wagon condition with code \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_condition!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Wagon Condition deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(commodity, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, commodity)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Wagon condition with code \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:wagon_condition, :create}
      act when act in ~w(index)a -> {:wagon_condition, :index}
      act when act in ~w(update edit)a -> {:wagon_condition, :edit}
      act when act in ~w(change_status)a -> {:wagon_condition, :change_status}
      act when act in ~w(delete)a -> {:wagon_condition, :delete}
      _ -> {:wagon_condition, :unknown}
    end
  end
end
