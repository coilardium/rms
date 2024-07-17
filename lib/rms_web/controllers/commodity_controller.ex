defmodule RmsWeb.CommodityController do
  use RmsWeb, :controller
  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.Commodity
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
       [module_callback: &RmsWeb.CommodityController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    commodity_group =
      SystemUtilities.list_tbl_commodity_group() |> Enum.reject(&(&1.status != "A"))

    commodity = SystemUtilities.list_tbl_commodity()
    render(conn, "index.html", commodity: commodity, commodity_group: commodity_group)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create_commodity: _create_commodity, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Commodity Created successfully")
        |> redirect(to: Routes.commodity_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.commodity_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create_commodity, Commodity.changeset(%Commodity{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create_commodity: create_commodity} ->
      activity = "New Commodity created with code \"#{create_commodity.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    commodity = SystemUtilities.get_commodity!(id)
    user = conn.assigns.user

    handle_update(user, commodity, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Commodity updated successful")
        |> redirect(to: Routes.commodity_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.commodity_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    commodity = SystemUtilities.get_commodity!(id)
    user = conn.assigns.user

    handle_update(user, commodity, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, commodity, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Commodity.changeset(commodity, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated commodity code with \"#{update.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_commodity!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "commodity deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(loco_type, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, loco_type)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted commodity code with \"#{del.code}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def upadte_commodity_code() do
    items = SystemUtilities.list_tbl_commodity()

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      commodity_code = String.pad_leading("#{index}", 4, "0")

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:station, index},
        Commodity.changeset(item, %{commodity_code: commodity_code})
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

  def upadte_commodity_desc() do
    items = SystemUtilities.list_tbl_commodity()

    Enum.with_index(items, 1)
    |> Enum.map(fn {item, index} ->
      description = String.capitalize(item.description)
      code =  String.capitalize(item.code)

      Ecto.Multi.new()
      |> Ecto.Multi.update(
        {:station, index},
        Commodity.changeset(item, %{description: description, code: code})
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

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(new create)a -> {:commodity, :create}
      act when act in ~w(index)a -> {:commodity, :index}
      act when act in ~w(update edit)a -> {:commodity, :edit}
      act when act in ~w(change_status)a -> {:commodity, :change_status}
      act when act in ~w(delete)a -> {:commodity, :delete}
      _ -> {:commodity, :unknown}
    end
  end
end
