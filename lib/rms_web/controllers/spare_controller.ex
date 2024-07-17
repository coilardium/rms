defmodule RmsWeb.SpareController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities
  alias Rms.SystemUtilities.Spare
  alias Rms.Logs.UserLog
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
       [module_callback: &RmsWeb.SpareController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    spares = SystemUtilities.list_tbl_spares()
    render(conn, "index.html", spares: spares)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, %{create: _create, user_log: _user_log}} ->
        conn
        |> put_flash(:info, "Spare created successfully")
        |> redirect(to: Routes.spare_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.spare_path(conn, :index))
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:create, Spare.changeset(%Spare{}, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Created spare \"#{create.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def update(conn, %{"id" => id} = params) do
    spare = SystemUtilities.get_spare!(id)
    user = conn.assigns.user

    handle_update(user, spare, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Spare updated successful")
        |> redirect(to: Routes.spare_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.spare_path(conn, :index))
    end
  end

  def change_status(conn, %{"id" => id} = params) do
    spare = SystemUtilities.get_spare!(id)
    user = conn.assigns.user

    handle_update(user, spare, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, spare, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, Spare.changeset(spare, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated Spare \"#{update.description}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def delete(conn, %{"id" => id}) do
    SystemUtilities.get_spare!(id)
    |> handle_delete(conn.assigns.user)
    |> Repo.transaction()
    |> case do
      {:ok, %{del: _del, user_log: _user_log}} ->
        conn |> json(%{"info" => "Spare deleted successfully."})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        conn |> json(%{"error" => reason})
    end
  end

  defp handle_delete(spare, user) do
    Ecto.Multi.new()
    |> Ecto.Multi.delete(:del, spare)
    |> Ecto.Multi.run(:user_log, fn repo, %{del: del} ->
      activity = "Deleted spare \"#{del.description}\""

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
      act when act in ~w(new create)a -> {:spare, :create}
      act when act in ~w(index)a -> {:spare, :index}
      act when act in ~w(update edit)a -> {:spare, :edit}
      act when act in ~w(change_status)a -> {:spare, :change_status}
      act when act in ~w(delete)a -> {:spare, :delete}
      _ -> {:spare, :unknown}
    end
  end


  # @headers ~w/code description maker_id checker_id status /a

  # def extract_xlsx(path) do
  #   case Xlsxir.multi_extract(path, 0, false, extract_to: :memory) do
  #     {:ok, id} ->
  #       items =
  #         Xlsxir.get_list(id)
  #         |> Enum.reject(&Enum.empty?/1)
  #         |> Enum.reject(&Enum.all?(&1, fn item -> is_nil(item)
  #       end))
  #         |> List.delete_at(0)
  #         |> Enum.map(
  #           &Enum.zip(
  #             Enum.map(@headers, fn h -> h end),
  #             Enum.map(&1, fn v -> strgfy_term(v) end)
  #           )
  #         )
  #         |> Enum.map(&Enum.into(&1, %{}))
  #         |> Enum.reject(&(Enum.join(Map.values(&1)) == ""))

  #       Xlsxir.close(id)
  #       {:ok, items}

  #     {:error, reason} ->
  #       {:error, reason}
  #   end
  # end

  # defp strgfy_term(term) when is_tuple(term), do: term
  # defp strgfy_term(term) when not is_tuple(term), do: String.trim("#{term}")

  # def upload_excel(params) do
  #   Ecto.Multi.new()
  #   |> Ecto.Multi.insert(:create, Spare.changeset(%Spare{}, params))
  #   |> Ecto.Multi.run(:insert, fn repo, %{create: create} ->

  #     rate = Map.merge(params, %{spare_id: create.id })

  #     Spare.changeset(%Spare{}, rate)
  #     |> repo.insert()
  #   end)

  #   # |> handle_rates_excel(params)
  #   |> Repo.transaction()
  #   |> IO.inspect()
  # end

  # defp handle_rates_excel( muilt, params) do
  #   items = params
  #     Ecto.Multi.merge(muilt, fn %{:create =>  spare} ->
  #       Enum.with_index(items, 1)
  #       # |> Enum.map(fn {item, index} ->

  #         Ecto.Multi.new()

  #       # end)
  #       |> Enum.reduce(Ecto.Multi.new(), &Ecto.Multi.append/2)
  #     end)
  # end

  # {:ok, items} = RmsWeb.SpareController.extract_xlsx("C:/Users/Admin/OneDrive/Desktop/spares.xlsx")

  # Enum.each(items, fn x -> RmsWeb.SpareController.upload_excel(x) end)

  # {:ok, items} = RmsWeb.SpareController.extract_xlsx("D:/wagon.xlsx")

  # Enum.each(items, fn x -> RmsWeb.SpareController.handle_create(x) end)

  # def handle_create(params) do

  #   Ecto.Multi.new()
  #   |> Ecto.Multi.insert(:create,  Rms.SystemUtilities.Spare.changeset(%Rms.SystemUtilities.Spare{}, params))
  #   |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
  #     activity = "New spare created with code \"#{create.description}\""

  #     user_log = %{
  #       user_id: 1,
  #       activity: activity
  #     }

  #     UserLog.changeset(%UserLog{}, user_log)
  #     |> repo.insert()
  #   end)
  #   |> IO.inspect()
  #   |> Repo.transaction()
  # end
end
