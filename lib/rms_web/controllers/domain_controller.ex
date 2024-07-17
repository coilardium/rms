defmodule RmsWeb.DomainController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.Domain
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
       [module_callback: &RmsWeb.DomainController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    domain = SystemUtilities.list_tbl_domain()
    render(conn, "index.html", domain: domain)
  end

  def new(conn, _params) do
    changeset = SystemUtilities.change_domain(%Domain{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Domain created successfully")
        |> redirect(to: Routes.domain_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.domain_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Domain.changeset(%Domain{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Created domain \"#{create.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    domain = SystemUtilities.get_domain!(id)
    user = conn.assigns.user

    handle_update(user, domain, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Domain updated successful")
        |> redirect(to: Routes.domain_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.domain_path(conn, :index))
    end
  end

  defp handle_update(user, domain, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Domain.changeset(domain, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Domain \"#{update.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def change_status(conn, %{"id" => id} = params) do
    domain = SystemUtilities.get_domain!(id)
    user = conn.assigns.user

    handle_update(user, domain, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_domain!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Domain deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(domain, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, domain)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Domain with \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:domain, :create}
      act when act in ~w(index)a -> {:domain, :index}
      act when act in ~w(update edit)a -> {:domain, :edit}
      act when act in ~w(change_status)a -> {:domain, :change_status}
      act when act in ~w(delete)a -> {:domain, :delete}
      _ -> {:domain, :unknown}
    end
  end
end
