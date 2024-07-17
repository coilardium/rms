defmodule RmsWeb.CurrencyController do
  use RmsWeb, :controller

  # alias Rms.Currencies
  alias Rms.SystemUtilities.Currency
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
       [module_callback: &RmsWeb.CurrencyController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    currency = SystemUtilities.list_tbl_currency()
    render(conn, "index.html", currency: currency)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Currency created successfully")
        |> redirect(to: Routes.currency_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.currency_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Currency.changeset(%Currency{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Currency created  with acronym \"#{create.acronym}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    currency = SystemUtilities.get_currency!(id)
    user = conn.assigns.user

    handle_update(user, currency, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Currency updated successful")
        |> redirect(to: Routes.currency_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.currency_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    currency = SystemUtilities.get_currency!(id)
    user = conn.assigns.user

    handle_update(user, currency, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, currency, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Currency.changeset(currency, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Currency with acronym \"#{update.acronym}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_currency!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Currency deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(currency, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, currency)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Currency  with acronym \"#{del.acronym}\""

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
      act when act in ~w(new create)a -> {:currency, :create}
      act when act in ~w(index)a -> {:currency, :index}
      act when act in ~w(update edit)a -> {:currency, :edit}
      act when act in ~w(change_status)a -> {:currency, :change_status}
      act when act in ~w(delete)a -> {:currency, :delete}
      _ -> {:currency, :unknown}
    end
  end
end
