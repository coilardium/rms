defmodule RmsWeb.TrainTypeController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.TrainType
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
       [module_callback: &RmsWeb.TrainTypeController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    train_type = SystemUtilities.list_tbl_train_type()
    render(conn, "index.html", train_type: train_type)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{train_type: _train_type, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Train Type Created successfully.")
        |> redirect(to: Routes.train_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.train_type_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:train_type, TrainType.changeset(%TrainType{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{train_type: train_type} ->
      activity = "Created new train type with code \"#{train_type.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    train_type = SystemUtilities.get_train_type!(id)
    user = conn.assigns.user

    handle_update(user, train_type, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "train type updated successful")
        |> redirect(to: Routes.train_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.train_type_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    train_type = SystemUtilities.get_train_type!(id)
    user = conn.assigns.user

    handle_update(user, train_type, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, train_type, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, TrainType.changeset(train_type, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated train type with description \"#{update.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_train_type!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Train type deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(train_type, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, train_type)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted train type for  \"#{del.description}\""

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
      act when act in ~w(new create)a -> {:train_type, :create}
      act when act in ~w(index)a -> {:train_type, :index}
      act when act in ~w(update edit)a -> {:train_type, :edit}
      act when act in ~w(change_status)a -> {:train_type, :change_status}
      act when act in ~w(delete)a -> {:train_type, :delete}
      _ -> {:train_type, :unknown}
    end
  end
end
