defmodule RmsWeb.WagonController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.Wagon
  alias Rms.SystemUtilities
  alias Rms.{Repo, Activity.UserLog}
  alias Rms.Accounts
  alias RmsWeb.InterchangeController

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.WagonController.authorize/1]
       when action not in [:unknown, :wagon_lookup]

  @current "tbl_wagon"

  def index(conn, _params) do
    wagon_type = SystemUtilities.list_tbl_wagon_type() |> Enum.reject(&(&1.status != "A"))
    clients = Accounts.list_tbl_clients() |> Enum.reject(&(&1.status != "A"))
    conditions = SystemUtilities.list_tbl_condition() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    wagon_status = SystemUtilities.list_tbl_status() |> Enum.reject(&(&1.rec_status != "A"))
    commodity = SystemUtilities.list_tbl_commodity() |> Enum.reject(&(&1.status != "A"))
    # wagon = SystemUtilities.list_tbl_wagon()

    railway_administrator =
      Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))

    render(conn, "index.html",
      # wagon: wagon,
      wagon_type: wagon_type,
      railway_administrator: railway_administrator,
      clients: clients,
      conditions: conditions,
      stations: stations,
      commodity: commodity,
      wagon_status: wagon_status
    )
  end

  def wagon_fleet_lookup(conn, params) do
    {draw, start, length, search_params} = InterchangeController.search_options(params)

    results = SystemUtilities.wagon_fleet_lookup(search_params, start, length, conn.assigns.user)

    total_entries = InterchangeController.total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: InterchangeController.entries(results)
    }

    json(conn, results)
  end

  def wagon_fleet_excel(conn, params) do
    entries = process_report(conn, @current, params)
    user = conn.assigns.user

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=WAGON_FLEET_REPORT_#{Timex.today()}.xlsx"
    )
    |> render("report.xlsx", %{entries: entries, user: user, report_type: ""})
  end

  defp process_report(conn, source, params) do
    params
    |> Map.delete("_csrf_token")
    |> report_generator(source, conn.assigns.user)
    |> Repo.all()
  end

  def report_generator(search_params, source, user) do
    SystemUtilities.wagon_fleet_lookup(source, Map.put(search_params, "isearch", ""), user)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Wagon created successfully")
        |> redirect(to: Routes.wagon_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.wagon_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    station = SystemUtilities.get_station!(params["station_id"])
    commodity = SystemUtilities.get_commodity!(params["commodity_id"])

    params =
      Map.merge(params, %{
        "status" => "D",
        "maker_id" => user.id,
        "domain_id" => station.domain_id,
        "load_status" => commodity.load_status
      })

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Wagon.changeset(%Wagon{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Wagon created with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    wagon = SystemUtilities.get_wagon!(id)
    user = conn.assigns.user

    station = SystemUtilities.get_station!(params["station_id"])
    commodity = SystemUtilities.get_commodity!(params["commodity_id"])

    params =
      Map.merge(params, %{
        "status" => "D",
        "maker_id" => user.id,
        "domain_id" => station.domain_id,
        "load_status" => commodity.load_status,
        "checker_id" => user.id
      })

    handle_update(user, wagon, params)
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "wagon updated successful")
        |> redirect(to: Routes.wagon_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.wagon_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    wagon = SystemUtilities.get_wagon!(id)
    user = conn.assigns.user

    handle_update(user, wagon, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, wagon, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Wagon.changeset(wagon, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Wagon code with \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_wagon!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Wagon deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(commodity, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, commodity)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Wagon code with \"#{del.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def wagon_lookup(conn, %{"code" => code}) do
    wagon = SystemUtilities.wagon_lookup(String.trim(code))
    json(conn, %{"data" => List.wrap(wagon)})
  end

  # def wagon_lookup(conn, %{"code" => code}) do
  #   code = SystemUtilities.wagon_lookup(String.trim(code))
  #   json(conn, code)
  # end

  def allocate_wagon(conn, %{"id" => id} = params) do
    wagon = SystemUtilities.get_wagon!(id)
    user = conn.assigns.user

    handle_allocate(user, params, wagon)
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_allocate(user, params, wagon) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Wagon.changeset(wagon, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Wagon allocated with code \"#{update.code}\""

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
      act when act in ~w(new create)a -> {:wagon, :create}
      act when act in ~w(index wagon_fleet_lookup wagon_fleet_excel)a -> {:wagon, :index}
      act when act in ~w(update edit)a -> {:wagon, :edit}
      act when act in ~w(change_status)a -> {:wagon, :change_status}
      act when act in ~w(delete)a -> {:wagon, :delete}
      act when act in ~w(allocate_wagon)a -> {:wagon, :allocate_wagon}
      _ -> {:wagon, :unknown}
    end
  end
end
