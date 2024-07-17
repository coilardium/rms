defmodule RmsWeb.PaymentTypeController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.PaymentType
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
       [module_callback: &RmsWeb.PaymentTypeController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    payment_type = SystemUtilities.list_tbl_payment_type()
    render(conn, "index.html", payment_type: payment_type)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Payment type created successfully")
        |> redirect(to: Routes.payment_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.payment_type_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, PaymentType.changeset(%PaymentType{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New payment type created  with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    type = SystemUtilities.get_payment_type!(id)
    user = conn.assigns.user

    handle_update(user, type, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Payment type updated successful")
        |> redirect(to: Routes.payment_type_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.payment_type_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    type = SystemUtilities.get_payment_type!(id)
    user = conn.assigns.user

    handle_update(user, type, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, type, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, PaymentType.changeset(type, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated payment type with code \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_payment_type!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Payment type deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(type, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, type)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted payment type  with code \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:payment_type, :create}
      act when act in ~w(index)a -> {:payment_type, :index}
      act when act in ~w(update edit)a -> {:payment_type, :edit}
      act when act in ~w(change_status)a -> {:payment_type, :change_status}
      act when act in ~w(delete)a -> {:payment_type, :delete}
      _ -> {:payment_type, :unknown}
    end
  end
end
