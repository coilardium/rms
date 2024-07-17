defmodule RmsWeb.LocomotiveController do
  use RmsWeb, :controller

  alias Rms.{Locomotives, SystemUtilities}
  alias Rms.Locomotives.Locomotive
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
       [module_callback: &RmsWeb.LocomotiveController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    owners = Rms.Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    locomotive_type = Locomotives.list_tbl_locomotive_type() |> Enum.reject(&(&1.status != "A"))
    models = SystemUtilities.list_tbl_locomotive_models() |> Enum.reject(&(&1.status != "A"))
    locomotive = Locomotives.list_tbl_locomotive()

    render(conn, "index.html",
      locomotive: locomotive,
      locomotive_type: locomotive_type,
      models: models,
      owners: owners
    )
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_locomotive: _create_locomotive, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Locomotive Created successfully")
        |> redirect(to: Routes.locomotive_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.locomotive_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create_locomotive, Locomotive.changeset(%Locomotive{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create_locomotive: create_locomotive} ->
      activity = "Created new locomotive with loco number\"#{create_locomotive.loco_number}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, params) do
    item = Rms.Locomotives.get_locomotive!(params["id"])

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update_loco, Locomotive.changeset(item, params))
    |> Ecto.Multi.run(:user_log, fn _, %{update_loco: update_loco} ->
      activity = " update locomotive with loco number\"#{update_loco.loco_number}\""

      user_log = %{
        user_id: conn.assigns.user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> Repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{update_loco: _update, user_log: _insert}} ->
        conn
        |> put_flash(:info, "Locomotive Details Updated Successfully")
        |> redirect(to: Routes.locomotive_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.locomotive_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    Rms.Locomotives.get_locomotive!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Locomotive deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(loco, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, loco)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: _del} ->
      activity = "Deleted Locomotive loco number with \"#{loco.loco_number}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def change_status(conn, %{"id" => id} = params) do
    loco = Rms.Locomotives.get_locomotive!(id)
    user = conn.assigns.user

    handle_update(user, loco, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, loco, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Locomotive.changeset(loco, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: _update} ->
      activity = "Updated locomotive with loco number \"#{loco.loco_number}\""

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
      act when act in ~w(new create)a -> {:locomotive, :create}
      act when act in ~w(index)a -> {:locomotive, :index}
      act when act in ~w(update edit)a -> {:locomotive, :edit}
      act when act in ~w(change_status)a -> {:locomotive, :change_status}
      act when act in ~w(delete)a -> {:locomotive, :delete}
      _ -> {:locomotive, :unknown}
    end
  end
end
