defmodule RmsWeb.DistanceController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.Distance
  alias Rms.Logs.UserLog
  alias Rms.{Repo, Activity.UserLog}
  alias RmsWeb.InterchangeController

  @current "tbl_distance"

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [:unknown]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [:unknown]
  )

  plug RmsWeb.Plugs.Authenticate,
       [module_callback: &RmsWeb.DistanceController.authorize/1]
       when action not in [:unknown, :distnace_km_lookup, :distance_excel]

  def index(conn, _params) do
    stations = SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    distance = SystemUtilities.list_tbl_distance()

    render(conn, "index.html", distance: distance, stations: stations)
  end

  def filter_distance_lookup(conn, params) do
    {draw, start, length, search_params} = InterchangeController.search_options(params)

    results =
      SystemUtilities.filter_distance_lookup(search_params, start, length, conn.assigns.user)

    total_entries = InterchangeController.total_entries(results)

    results = %{
      draw: draw,
      recordsTotal: total_entries,
      recordsFiltered: total_entries,
      data: InterchangeController.entries(results)
    }

    json(conn, results)
  end

  def distance_excel(conn, params) do
    entries = process_report(conn, @current, params)
    user = conn.assigns.user

    conn
    |> put_resp_content_type("text/xlsx")
    |> put_resp_header(
      "content-disposition",
      "attachment; filename=DISTANCE_REPORT_#{Timex.today()}.xlsx"
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
    SystemUtilities.filter_distance_lookup(source, Map.put(search_params, "isearch", ""), user)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Distance created successfully")
        |> redirect(to: Routes.distance_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.distance_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Distance.changeset(%Distance{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Distance created for \"#{create.destin}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    distance = SystemUtilities.get_distance!(id)
    user = conn.assigns.user

    handle_update(user, distance, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "distance updated successful")
        |> redirect(to: Routes.distance_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.distance_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    distance = SystemUtilities.get_distance!(id)
    user = conn.assigns.user

    handle_update(user, distance, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, distance, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Distance.changeset(distance, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated station with acronym \"#{update.destin}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_distance!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Distnce deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(distance, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, distance)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted distance for  \"#{del.destin}\""

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

  def distnace_km_lookup(conn, %{"destin" => destin, "station_orig" => station_orig}) do
    distance = Rms.SystemUtilities.distance_lookup(destin, station_orig)
    json(conn, %{"data" => List.wrap(distance)})
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(new create)a -> {:distance, :create}
      act when act in ~w(index filter_distance_lookup)a -> {:distance, :index}
      act when act in ~w(update edit)a -> {:distance, :edit}
      act when act in ~w(change_status)a -> {:distance, :change_status}
      act when act in ~w(delete)a -> {:distance, :delete}
      _ -> {:distance, :unknown}
    end
  end
end
