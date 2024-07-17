defmodule RmsWeb.MovementExceptionController do
  use RmsWeb, :controller

  alias Rms.MovementExceptions
  alias Rms.MovementExceptions.MovementException
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
       [module_callback: &RmsWeb.MovementExceptionController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    mvt_exceptions = MovementExceptions.list_tbl_mvt_exceptions()
    render(conn, "index.html", mvt_exceptions: mvt_exceptions)
  end

  def new(conn, _params) do
    changeset = MovementExceptions.change_movement_exception(%MovementException{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Exception created successfully")
        |> redirect(to: Routes.movement_exception_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.movement_exception_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, MovementException.changeset(%MovementException{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New exception created  on \"#{create.capture_date}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    exception = MovementExceptions.get_movement_exception!(id)
    user = conn.assigns.user

    handle_update(user, exception, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "exception updated successful")
        |> redirect(to: Routes.movement_exception_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.movement_exception_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    exception = MovementExceptions.get_movement_exception!(id)
    user = conn.assigns.user

    handle_update(user, exception, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, exception, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, MovementException.changeset(exception, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated exception on \"#{update.capture_date}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    MovementExceptions.get_movement_exception!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "exception deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(exception, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, exception)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted exception on \"#{del.capture_date}\""

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
      act when act in ~w(new create)a -> {:mvt_exceptions, :create}
      act when act in ~w(index)a -> {:mvt_exceptions, :index}
      act when act in ~w(update edit)a -> {:mvt_exceptions, :edit}
      act when act in ~w(change_status)a -> {:mvt_exceptions, :change_status}
      act when act in ~w(delete)a -> {:mvt_exceptions, :delete}
      _ -> {:mvt_exceptions, :unknown}
    end
  end
end
