defmodule RmsWeb.CompanyInfoController do
  use RmsWeb, :controller

  alias Rms.SystemUtilities.CompanyInfo
  alias Rms.Accounts
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
       [module_callback: &RmsWeb.CompanyInfoController.authorize/1]
       when action not in [:unknown]

  def index(conn, _params) do
    admins = Accounts.list_tbl_railway_administrator() |> Enum.reject(&(&1.status != "A"))
    currency = SystemUtilities.list_tbl_currency() |> Enum.reject(&(&1.status != "A"))
    company = SystemUtilities.list_company_info()
    render(conn, "index.html", company: company, admins: admins, currency: currency)
  end

  def create(conn, params) do
    conn.assigns.user
    |> handle_create(params)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        json(conn, %{info: "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{error: reason})
    end
  end

  defp handle_create(user, params) do
    params = Map.merge(params, %{"status" => "D", "maker_id" => user.id})

    entry =
      if(to_string(params["id"]) == "",
        do: %CompanyInfo{maker_id: user.id},
        else: SystemUtilities.get_company_info!(params["id"])
      )

    Ecto.Multi.new()
    |> Ecto.Multi.insert_or_update(:create, CompanyInfo.changeset(entry, params))
    |> Ecto.Multi.run(:user_log, fn repo, %{create: create} ->
      activity = "New Company Info created  \"#{create.company_name}\""

      user_log = %{
        user_id: user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, user_log)
      |> repo.insert()
    end)
  end

  def change_status(conn, %{"id" => id} = params) do
    company = SystemUtilities.get_company_info!(id)
    user = conn.assigns.user

    handle_update(user, company, Map.put(params, "checker_id", user.id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{"info" => "Changes applied successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()
        json(conn, %{"error" => reason})
    end
  end

  defp handle_update(user, company, params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, CompanyInfo.changeset(company, params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: update} ->
      activity = "Updated company \"#{update.company_name}\""

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
      act when act in ~w(new create)a -> {:company_info, :create}
      act when act in ~w(index)a -> {:company_info, :index}
      _ -> {:company_info, :unknown}
    end
  end
end
