defmodule RmsWeb.TrainRouteController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.TrainRoute
  alias Rms.{Repo, Activity.UserLog}
  alias Rms.SystemUtilities
  alias Rms.Accounts
  alias RmsWeb.InterchangeController

  @current "tbl_train_routes"

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.TrainRouteController.authorize/1]
       when action not in [:unknown, :train_route_excel]

  def index(conn, _params) do
    tbl_train_routes = SystemUtilities.list_tbl_train_routes()
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    transport_type = SystemUtilities.list_tbl_transport_type() |> Enum.reject(&(&1.status != "A"))

    railway_administrator =
      Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))

    render(conn, "index.html",
      tbl_train_routes: tbl_train_routes,
      stations: stations,
      transport_type: transport_type,
      railway_administrator: railway_administrator
    )
  end

  def train_route_lookup(conn, params) do
    {draw, start, length, search_params} = InterchangeController.search_options(params)

    results = SystemUtilities.train_route_lookup(search_params, start, length, conn.assigns.user)

    total_entries = InterchangeController.total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: InterchangeController.entries(results)
    }

    json(conn, results)
  end

  def train_route_excel(conn, params) do
    entries = process_report(conn, @current, params)
    user = conn.assigns.user

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=ROUTES_REPORT_#{Timex.today()}.xlsx"
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
    SystemUtilities.train_route_lookup(source, Map.put(search_params, "isearch", ""), user)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Route created successfully")
        |> redirect(to: Routes.train_route_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.train_route_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, TrainRoute.changeset(%TrainRoute{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Route created  with code \"#{create.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    route = SystemUtilities.get_train_route!(id)
    user = conn.assigns.user

    handle_update(user, route, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Route updated successful")
        |> redirect(to: Routes.train_route_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.train_route_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    route = SystemUtilities.get_train_route!(id)
    user = conn.assigns.user

    handle_update(user, route, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, route, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, TrainRoute.changeset(route, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated route with code \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_train_route!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Route deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(commodity, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, commodity)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Route with code \"#{del.code}\""

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
      act when act in ~w(new create)a -> {:train_route, :create}
      act when act in ~w(index train_route_lookup)a -> {:train_route, :index}
      act when act in ~w(update edit)a -> {:train_route, :edit}
      act when act in ~w(change_status)a -> {:train_route, :change_status}
      act when act in ~w(delete)a -> {:train_route, :delete}
      _ -> {:train_route, :unknown}
    end
  end
end
