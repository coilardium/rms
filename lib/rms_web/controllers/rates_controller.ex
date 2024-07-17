defmodule RmsWeb.RatesController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.Rates
  alias Rms.Activity.UserLog
  alias Rms.{Repo}
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
       [module_callback: &RmsWeb.RatesController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    rates = SystemUtilities.list_tbl_fuel_rates()
    distance = SystemUtilities.list_tbl_distance()
    stations = SystemUtilities.list_tbl_station()
    render(conn, "index.html", rates: rates, distance: distance, stations: stations)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Fuel rate created successfully")
        |> redirect(to: Routes.rates_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.rates_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Rates.changeset(%Rates{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Fuel rate created  with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    rate = SystemUtilities.get_rates!(id)
    user = conn.assigns.user

    handle_update(user, rate, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Fuel rate updated successful")
        |> redirect(to: Routes.rates_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.rates_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    rate = SystemUtilities.get_rates!(id)
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
    |> Ecto.Multi.update(:update, Rates.changeset(rate, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Fuel rate with code \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_rates!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Fuel rate deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(commodity, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, commodity)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Fuel rate with code \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:rate, :create}
      act when act in ~w(index)a -> {:rate, :index}
      act when act in ~w(update edit)a -> {:rate, :edit}
      act when act in ~w(change_status)a -> {:rate, :change_status}
      act when act in ~w(delete)a -> {:rate, :delete}
      _ -> {:rate, :unknown}
    end
  end
end
