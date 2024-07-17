defmodule RmsWeb.NotificationController do
  use RmsWeb, :controller

  alias Rms.Notifications
  alias Rms.Notifications.Email
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
       [module_callback: &RmsWeb.NotificationController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    emails = Notifications.list_tbl_email_alerts()
    render(conn, "index.html", emails: emails)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Email alerts created successfully")
        |> redirect(to: Routes.notification_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.notification_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Email.changeset(%Email{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "email alert \"#{create.email}\" with alert type \"#{create.type}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, params) do
    item = Notifications.get_email!(params["id"])

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Email.changeset(item, params))
    |> Ecto.Multi.run(:user_log, fn _, %{update: update} ->
      activity = "updated email alert \"#{update.email}\" with alert type \"#{update.type}\""

      user_log = %{
        user_id: conn.assigns.user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, user_log: _insert}} ->
        conn
        |> put_flash(:info, "Email alert Updated Successfully")
        |> redirect(to: Routes.notification_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.notification_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    Notifications.get_email!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Email Alert deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(email, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, email)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: _del} ->
      activity = "Deleted email alert \"#{email.email}\" with alert type \"#{email.type}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def change_status(conn, %{"id" => id} = params) do
    email = Notifications.get_email!(id)
    user = conn.assigns.user

    handle_update(user, email, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, email, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Email.changeset(email, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: _update} ->
      activity = "Updated email alert \"#{email.email}\" with alert type \"#{email.type}\""

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
      act when act in ~w(new create)a -> {:notification, :create}
      act when act in ~w(index)a -> {:notification, :index}
      act when act in ~w(update edit)a -> {:notification, :edit}
      act when act in ~w(change_status)a -> {:notification, :change_status}
      act when act in ~w(delete)a -> {:notification, :delete}
      _ -> {:notification, :unknown}
    end
  end
end
