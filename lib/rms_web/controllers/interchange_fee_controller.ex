defmodule RmsWeb.InterchangeFeeController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.InterchangeFee
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
       [module_callback: &RmsWeb.InterchangeFeeController.authorize/1]
       when action not in [:unknown, :interchange_fee_lookup]

  def index(conn, _params) do
    currency =
      SystemUtilities.list_tbl_currency()

    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    wagon_type = SystemUtilities.list_tbl_wagon_type() |> Enum.reject(&(&1.status != "A" or &1.category != "SUB"))
    fees = SystemUtilities.list_tbl_interchange_fees()

    render(conn, "index.html",
      fees: fees,
      currency: currency,
      admins: admins,
      wagon_type: wagon_type
    )
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Wagon rate created successfully")
        |> redirect(to: Routes.interchange_fee_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.interchange_fee_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, InterchangeFee.changeset(%InterchangeFee{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity =
        "New Wagon rate for partner \"#{create.partner_id}\" date #{create.effective_date} for wagon type #{create.wagon_type_id}"

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    fee = SystemUtilities.get_interchange_fee!(id)
    user = conn.assigns.user

    handle_update(user, fee, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Wagon rate updated successful")
        |> redirect(to: Routes.interchange_fee_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.interchange_fee_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    fee = SystemUtilities.get_interchange_fee!(id)
    user = conn.assigns.user

    handle_update(user, fee, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, fee, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, InterchangeFee.changeset(fee, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity =
        "Updated Wagon rate for partner \"#{update.partner_id}\" date #{update.effective_date} for wagon type #{update.wagon_type_id}"

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_interchange_fee!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Wagon rate deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(fee, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, fee)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity =
        "Deleted Wagon rate for partner \"#{del.partner_id}\" date #{del.effective_date} for wagon type #{del.wagon_type_id}"

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def interchange_fee_lookup(conn, %{
        "date" => date,
        "adminstrator_id" => adminstrator_id,
        "wagon_id" => wagon_id
      }) do
    wagon_type_id = SystemUtilities.get_wagon!(wagon_id).wagon_type_id

    fee =
      SystemUtilities.interchange_fee_lookup(
        String.slice(date, 0..-7),
        adminstrator_id,
        wagon_type_id
      )

    json(conn, %{"data" => List.wrap(fee)})
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(new create)a -> {:interchange_fee, :create}
      act when act in ~w(index)a -> {:interchange_fee, :index}
      act when act in ~w(update edit)a -> {:interchange_fee, :edit}
      act when act in ~w(change_status)a -> {:interchange_fee, :change_status}
      act when act in ~w(delete)a -> {:interchange_fee, :delete}
      _ -> {:interchange_fee, :unknown}
    end
  end
end
