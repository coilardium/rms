defmodule RmsWeb.HaulageRateController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.HaulageRate
  alias Rms.Logs.UserLog
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
       [module_callback: &RmsWeb.HaulageRateController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    currency =
      SystemUtilities.list_tbl_currency()

    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    rates = SystemUtilities.list_tbl_haulage_rates()
    render(conn, "index.html", rates: rates, currency: currency, admins: admins)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Haulage Rate created successfully")
        |> redirect(to: Routes.haulage_rate_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.haulage_rate_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, HaulageRate.changeset(%HaulageRate{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity =
        "New Haulage rate for Admin \"#{create.admin_id}\" Start date #{create.start_date}"

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    rate = SystemUtilities.get_haulage_rate!(id)
    user = conn.assigns.user

    handle_update(user, rate, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Haulage Rate updated successful")
        |> redirect(to: Routes.haulage_rate_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.haulage_rate_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    rate = SystemUtilities.get_haulage_rate!(id)
    user = conn.assigns.user

    handle_update(user, rate, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, rate, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, HaulageRate.changeset(rate, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity =
        "Updated Haulage rate for Admin \"#{update.admin_id}\" start date #{update.start_date}"

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_haulage_rate!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Haulage Rate deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(fee, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, fee)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Haulage rate for admin \"#{del.admin_id}\" start date #{del.start_date}"

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
      act when act in ~w(new create)a -> {:haulage_rate, :create}
      act when act in ~w(index)a -> {:haulage_rate, :index}
      act when act in ~w(update edit)a -> {:haulage_rate, :edit}
      act when act in ~w(change_status)a -> {:haulage_rate, :change_status}
      act when act in ~w(delete)a -> {:haulage_rate, :delete}
      _ -> {:haulage_rate, :unknown}
    end
  end
end
