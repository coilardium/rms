defmodule RmsWeb.StationsController do
  use RmsWeb, :controller

  alias Rms.Station
  alias Rms.SystemUtilities.Station
  alias Rms.SystemUtilities
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
       [module_callback: &RmsWeb.StationsController.authorize/1]
       when action not in [:unknown, :station_lookup]

  def index(conn, _params) do
    region = SystemUtilities.list_tbl_region() |> Enum.reject(&(&1.status != "A"))
    owners = Rms.Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    domain = SystemUtilities.list_tbl_domain() |> Enum.reject(&(&1.status != "A"))
    stations = SystemUtilities.list_tbl_station()
    render(conn, "index.html", owners: owners, stations: stations, domain: domain, region: region)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Station created successfully")
        |> redirect(to: Routes.stations_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.stations_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Station.changeset(%Station{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New station created  with acronym \"#{create.acronym}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    station = SystemUtilities.get_station!(id)
    user = conn.assigns.user

    handle_update(user, station, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "station updated successful")
        |> redirect(to: Routes.stations_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.stations_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    station = SystemUtilities.get_station!(id)
    user = conn.assigns.user

    handle_update(user, station, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, station, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Station.changeset(station, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated station with acronym \"#{update.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_station!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Station deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(station, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, station)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted station  with acronym \"#{del.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def upadte_station_code() do
    items = SystemUtilities.list_tbl_station()

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      station_code = String.pad_leading("#{index}", 4, "0")

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:station, index},
        Station.changeset(item, %{station_code: station_code, interchange_point: "NO"})
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        %{"info" => "update successfully."}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        %{"error" => reason}
    end
  end

  def upadte_station_desc() do
    items = SystemUtilities.list_tbl_station()

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      description = String.capitalize(item.description)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:station, index},
        Station.changeset(item, %{description: description})
      )
    end)
    |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        %{"info" => "update successfully."}

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        %{"error" => reason}
    end
  end

  def station_lookup(conn, %{"id" => id}) do
    wagon = SystemUtilities.station_lookup(id)

    wagon = %{
      wagon
      | updated_at: Timex.format!(wagon.updated_at, "%d/%m/%Y %H:%M:%S", :strftime),
        inserted_at: Timex.format!(wagon.inserted_at, "%d/%m/%Y %H:%M:%S", :strftime)
    }

    json(conn, %{"data" => wagon})
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(new create)a -> {:stations, :create}
      act when act in ~w(index)a -> {:stations, :index}
      act when act in ~w(update edit)a -> {:stations, :edit}
      act when act in ~w(change_status)a -> {:stations, :change_status}
      act when act in ~w(delete)a -> {:stations, :delete}
      _ -> {:stations, :unknown}
    end
  end
end
