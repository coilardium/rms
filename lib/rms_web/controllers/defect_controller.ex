defmodule RmsWeb.DefectController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.Defect
  # alias Rms.SystemUtilities.DefectSpare
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
       [module_callback: &RmsWeb.DefectController.authorize/1]
       when action not in [:unknown, :defects_lookup, :defect_spare_lookup]

  def index(conn, %{"type" => type}) do
    defects = SystemUtilities.list_tbl_defects(String.upcase(type))
    spares = SystemUtilities.list_tbl_spares() |> Enum.reject(&(&1.status != "A"))

    currency =
      SystemUtilities.list_tbl_currency()
      |> Enum.reject(&(&1.id != SystemUtilities.list_company_info().prefered_ccy_id))

    surcharge = SystemUtilities.list_tbl_surcharge() |> Enum.reject(&(&1.status != "A"))

    render(conn, "index.html",
      defects: defects,
      spares: spares,
      type: type,
      currency: currency,
      surcharge: surcharge
    )
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{info: "Defect created successfully"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{error: reason})
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Defect.changeset(%Defect{}, params))
    |> Ecto.Multi.insert(
      {:user_log},
      UserLog.changeset(%UserLog{}, %{
        user_id: user.id,
        activity: "Defect #{params["description"]} created successfully"
      })
    )
  end

  def update(conn, %{"id" => id} = params) do
    defect = SystemUtilities.get_defect!(id)
    user = conn.assigns.user

    handle_update(user, defect, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, defect, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Defect.changeset(defect, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Defect\"#{update.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def change_status(conn, %{"id" => id} = params) do
    defect = SystemUtilities.get_defect!(id)
    user = conn.assigns.user

    handle_change_status(user, defect, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_change_status(user, defect, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Defect.changeset(defect, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Defect\"#{update.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_defect!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Defect deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(defect, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, defect)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted Defect \"#{del.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def defects_lookup(conn, %{"tracker_id" => tracker_id, "wagon_id" => wagon_id}) do
    ids =
      case SystemUtilities.tracker_entry_lookup(tracker_id, wagon_id) do
        nil -> []
        wagons -> wagons.defect_ids |> Poison.decode!()
      end

    spares = Rms.Tracking.defect_spares_lookup(tracker_id, wagon_id)
    data = Rms.SystemUtilities.get_defects_by_ids(ids)

    json(conn, %{"data" => List.wrap(data), "spares" => List.wrap(spares)})
  end

  def defect_spare_lookup(conn, %{"id" => id}) do
    spares = Rms.SystemUtilities.defect_spare_lookup(id)
    json(conn, %{"data" => List.wrap(spares)})
  end

  def delete_spare(conn, %{"id" => id}) do
    SystemUtilities.get_defect_spare!(id)
    |> handle_delete_spare(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Spare deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete_spare(tariff, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, tariff)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted spare \"#{del.spare_id}\" for defect  \"#{del.defect_id}\" "

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
      act when act in ~w(new create)a -> {:defect, :create}
      act when act in ~w(index)a -> {:defect, :index}
      act when act in ~w(update edit delete_spare)a -> {:defect, :edit}
      act when act in ~w(change_status)a -> {:defect, :change_status}
      act when act in ~w(delete)a -> {:defect, :delete}
      _ -> {:defect, :unknown}
    end
  end
end
