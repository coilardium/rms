defmodule RmsWeb.UserRoleController do
  use RmsWeb, :controller
  import Ecto.Query, warn: false
  alias Rms.Repo
  use PipeTo.Override
  alias Rms.Accounts
  alias Rms.Accounts.UserRole
  alias Rms.Activity.UserLog

  plug(RmsWeb.Plugs.RequireAuth when action not in [:unknown])

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.UserRoleController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    roles = Accounts.list_roles()
    render(conn, "index.html", roles: roles)
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def edit(conn, %{"id" => id}) do
    role =
      id
      |> Accounts.get_user_role!()
      |> Map.update!(:role_str, &AtomicMap.convert(&1, %{safe: false}))

    render(conn, "edit.html", role: role)
  end

  def update(conn, %{"user_role" => params, "role_str" => role_str}) do
    user_role = Accounts.get_user_role!(params["id"])
    params = Map.put(params, "role_str", role_str)

    conn.assigns.user
    |> handle_update(user_role, params)
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{info: "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{error: reason})
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    user_role = Accounts.get_user_role!(id)
    user = conn.assigns.user

    handle_update(user, user_role, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, user_role, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, UserRole.changeset(user_role, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: _update} ->
      activity = "Modified user role with user role desc #{user_role.role_desc}"

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def create(conn, %{"user_role" => params, "role_str" => role_str}) do
    params = Map.put(params, "role_str", role_str)

    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{user_role: user_role, user_log: _user_log}} ->
        json(conn, %{info: "#{user_role.role_desc} role creation successful"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{error: reason})
    end
  end

  defp handle_create(user, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :user_role,
      UserRole.changeset(%UserRole{maker_id: user.id, status: "D"}, params)
    )
    |> Ecto.Multi.run(:user_log, fn repo, %{user_role: user_role} ->
      activity = "Created new user role with user role desc: \"#{user_role.role_desc}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    Accounts.get_user_role!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "user_role deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(user_role, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, user_role)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted user_role with user_role Code \"#{del.role_desc}\""

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
      act when act in ~w(new create)a -> {:user_role, :create}
      act when act in ~w(index)a -> {:user_role, :index}
      act when act in ~w(update edit)a -> {:user_role, :edit}
      act when act in ~w(change_status)a -> {:user_role, :change_status}
      act when act in ~w(delete)a -> {:user_role, :delete}
      _ -> {:user_role, :unknown}
    end
  end
end
