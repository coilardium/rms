defmodule RmsWeb.ExchangeRateController do
  use RmsWeb, :controller
  # alias Rms.ExchangeRates
  alias Rms.SystemUtilities.ExchangeRate
  alias Rms.Logs.UserLog
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
       [module_callback: &RmsWeb.ExchangeRateController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    exchange_rate = SystemUtilities.list_tbl_exchange_rate()
    currency = SystemUtilities.list_tbl_currency() |> Enum.reject(&(&1.status != "A"))
    render(conn, "index.html", exchange_rate: exchange_rate, currency: currency)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Excahnge rate created successfully")
        |> redirect(to: Routes.exchange_rate_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.exchange_rate_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, ExchangeRate.changeset(%ExchangeRate{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Excahnge rate created \"#{create.exchange_rate}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    rate = SystemUtilities.get_exchange_rate!(id)
    user = conn.assigns.user

    handle_update(user, rate, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Excahnge rate updated successful")
        |> redirect(to: Routes.exchange_rate_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.exchange_rate_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    rate = SystemUtilities.get_exchange_rate!(id)
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
    |> Ecto.Multi.update(:update, ExchangeRate.changeset(rate, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Excharge rate  \"#{update.exchange_rate}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_exchange_rate!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Excharge rate deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(rate, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, rate)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Excharge rate \"#{del.exchange_rate}\""

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
      act when act in ~w(new create)a -> {:exchange_rate, :create}
      act when act in ~w(index)a -> {:exchange_rate, :index}
      act when act in ~w(update edit)a -> {:exchange_rate, :edit}
      act when act in ~w(change_status)a -> {:exchange_rate, :change_status}
      act when act in ~w(delete)a -> {:exchange_rate, :delete}
      _ -> {:exchange_rate, :unknown}
    end
  end
end
