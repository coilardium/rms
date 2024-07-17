defmodule RmsWeb.UserController do
  use RmsWeb, :controller
  import Ecto.Query, warn: false

  alias Rms.{Accounts.User, Repo}
  alias Rms.{Repo, Activity.UserLog}
  alias Rms.Accounts
  alias RmsWeb.Auth
  require Logger
  alias Rms.{Accounts.User, Auth, Accounts, Repo}
  alias Rms.Emails.Email
  require Logger

  plug(
    RmsWeb.Plugs.RequireAuth
    when action not in [
           :unknown,
           :reset_password,
           :new_password,
           :token,
           :perform_reset,
           :change_password,
           :forgot_password,
           :new_password
         ]
  )

  plug(
    RmsWeb.Plugs.EnforcePasswordPolicy
    when action not in [
           :unknown,
           :new_password,
           :perform_reset,
           :change_password,
           :forgot_password,
           :new_password,
           :reset_password,
           :token
         ]
  )

  plug(
    RmsWeb.Plugs.Authenticate,
    [module_callback: &RmsWeb.UserController.authorize/1]
    when action not in [
           :unknown,
           :new_password,
           :perform_reset,
           :reset_password,
           :dashboard,
           :token,
           :change_password,
           :forgot_password,
           :new_password,
           :user_logs
         ]
  )

  @dashboard_status_params ~w(
    CONSIGNMENT_PENDING_INVOICE
    CONSIGNMENT_PENDING_APPROVAL
    CONSIGNMENT_DISCARDED
    CONSIGNMENT_REJECTED
    CONSIGNMENT_PENDING_VERIFICATION
    CONSIGNMENT_COMPLETE
    MOVEMENT_COMPLETE
    MOVEMENT_DISCARED
    MOVEMENT_PENDING_VERIFICATION
    MOVEMENT_REJECTED
    FUEL_REQUISITE_COMPLETE
    FUEL_REQUISITE_PENDING_CONTROL
    FUEL_REQUISITE_PENDING_COMPLETION
    FUEL_REQUISITE_REJECTED
    FUEL_REQUISITE_PENDING_APPROVAL
  )
  def dashboard(conn, _params) do
    {stats, totals} =
      (Rms.Order.consignment_dashboard_params(conn.assigns.user) ++
         Rms.Order.movement_dashboard_params(conn.assigns.user) ++
         Rms.Order.fuel_requisite_dashboard_params(conn.assigns.user))
      |> Enum.sort_by(& &1.day)
      |> prepare_dash_result()
      |> prepare_stats_params()
      |> (&{&1, calcu_stats_totals(&1)}).()

    render(conn, "dashboard_layout.html",
      results: stats,
      summary: totals,
      wagons: total_loaded_wagons()
    )
  end

  defp prepare_dash_result(results) do
    Enum.reduce(default_dashboard(), results, fn item, acc ->
      filtered = Enum.filter(acc, &(&1.day == item.day))
      if item not in acc && Enum.empty?(filtered), do: [item | acc], else: acc
    end)
    |> Enum.sort_by(& &1.day)
  end

  defp default_dashboard do
    today = Date.utc_today()
    days = Date.days_in_month(today)

    Date.range(%{today | day: 1}, %{today | day: days})
    |> Enum.map(&%{count: 0, day: "#{&1}", status: nil})
  end

  defp calcu_stats_totals(results) do
    @dashboard_status_params
    |> Enum.map(fn status ->
      {status,
       Enum.reduce(
         results,
         &Map.merge(&1, %{
           status => (&1[status] || 0) + (&2[status] || 0)
         })
       )[status]}
    end)
    |> Enum.into(%{})
  end

  defp prepare_stats_params(items) do
    items
    |> Enum.map(
      &(Map.merge(Enum.into(Enum.map(@dashboard_status_params, fn key -> {key, 0} end), %{}), %{
          "date" => &1.day,
          &1.status => &1.count
        })
        |> Map.delete(nil))
    )
    |> Enum.group_by(& &1["date"])
    |> Map.values()
    |> Enum.map(fn item ->
      Enum.reduce(
        item,
        &Map.merge(&1, &2, fn k, v1, v2 -> if(k == "date", do: v1, else: v1 + v2) end)
      )
    end)
  end

  def status_value(values, status) do
    result = Enum.filter(values, &(&1.status == status))

    with false <- Enum.empty?(result) do
      Enum.reduce(result, &%{&1 | count: &1.count + &2.count}).count
    else
      _ -> 0
    end
  end

  def total_loaded_wagons() do
    wagons = Rms.SystemUtilities.total_loaded_wagons_lookup()

    case wagons do
      [] -> 0
      _ -> Enum.at(wagons, 0).count
    end
  end

  def index(conn, _params) do
    roles = Accounts.list_tbl_user_role() |> Enum.reject(&(&1.status != "A"))
    stations = Rms.SystemUtilities.list_tbl_station() |> Enum.reject(&(&1.status != "A"))
    users = Accounts.list_tbl_users()
    render(conn, "index.html", users: users, roles: roles, stations: stations)
  end

  def get_user_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, "invalid email address"}
      user -> {:ok, user}
    end
  end

  def get_user_reset_email(email) do
    case Repo.get_by(User, email: email, status: "A") do
      nil -> {:error, "invalid email address"}
      user -> {:ok, user}
    end
  end

  def new_password(conn, _params) do
    put_layout(conn, false)
    |> render("change_password.html")
  end

  def forgot_password(conn, _params) do
    put_layout(conn, false)
    |> render("forgot_password.html")
  end

  def change_password(conn, %{"user" => user_params}) do
    case confirm_old_password(conn, user_params) do
      false ->
        conn
        |> put_flash(:error, "Old password and New password can not be the same!")
        |> redirect(to: Routes.user_path(conn, :new_password))

      result ->
        with {:error, reason} <- result do
          conn
          |> put_flash(:error, reason)
          |> redirect(to: Routes.user_path(conn, :new_password))
        else
          {:ok, _} ->
            perform_reset(conn, user_params)
            |> Repo.transaction()
            |> case do
              {:ok, %{update: _update, insert: _insert}} ->
                conn
                |> put_flash(:info, "Password changed successfully!")
                |> redirect(to: Routes.user_path(conn, :dashboard))

              {:error, _failed_operation, failed_value, _changes_so_far} ->
                reason = traverse_errors(failed_value.errors) |> List.first()

                conn
                |> put_flash(:error, reason)
                |> redirect(to: Routes.user_path(conn, :new_password))
            end
        end
    end
  end

  def perform_reset(conn, user_params) do
    current_user = conn.assigns.user || conn.assigns.client
    user = Accounts.get_user!(current_user.id)
    pwd = String.trim(user_params["new_password"])
    expiry_days = Rms.SystemUtilities.list_company_info().password_expiry_days
    pwd_days = Timex.shift(Timex.today(), days: expiry_days)

    changeset =
      User.changeset(user, %{password: pwd, auto_password: "N", password_expiry_dt: pwd_days})

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, changeset)
    |> Ecto.Multi.insert(
      :insert,
      UserLog.changeset(
        %UserLog{},
        %{user_id: user.id, activity: "changed account password"}
      )
    )
  end

  defp confirm_old_password(conn, user_params) do
    with true <- String.trim(user_params["old_password"]) != "",
         true <- String.trim(user_params["new_password"]) != "",
         true <- is_old_and_new_same?(conn, user_params) do
      Auth.confirm_password(
        conn.assigns.user || conn.assigns.client,
        String.trim(user_params["old_password"])
      )
    else
      false -> false
    end
  end

  defp is_old_and_new_same?(conn, user_params) do
    case Auth.confirm_password(
           conn.assigns.user || conn.assigns.client,
           String.trim(user_params["new_password"])
         ) do
      {:error, _reason} -> true
      _ -> false
    end
  end

  def token(conn, %{"user" => user_params}) do
    with {:error, reason} <- get_user_reset_email(user_params["email"]) do
      conn
      |> put_flash(:error, reason)
      |> redirect(to: Routes.user_path(conn, :forgot_password))
    else
      {:ok, user} ->
        token =
          Phoenix.Token.sign(conn, "user salt", user.id, signed_at: System.system_time(:second))

        Email.confirm_password_reset(token, user.email)

        conn
        |> put_flash(:info, "We have sent you a mail")
        |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  defp confirm_token(conn, token) do
    case Phoenix.Token.verify(conn, "user salt", token, max_age: 86400) do
      {:ok, user_id} ->
        user = Repo.get!(User, user_id)
        {:ok, user}

      {:error, _} ->
        :error
    end
  end

  def reset_password(conn, %{"user_token" => token}) do
    with :error <- confirm_token(conn, token) do
      json(conn, %{"error" =>  "Invalid/Expired token"})
    else
      {:ok, user} ->
        pwd = random_string()

        case Accounts.update_user(user, %{password: pwd, auto_password: "Y"}) do
          {:ok, _user} ->
            Email.password_alert(user.email, pwd)
            json(conn, %{"info" => "Password Reset successfully!"})

          {:error, _reason} ->
            json(conn, %{"error" => "An error occured, try again!"})
        end
    end
  end

  def reset_password(conn, %{"token" => token}) do
    with :error <- confirm_token(conn, token) do
      conn
      |> put_flash(:error, "Invalid/Expired token")
      |> redirect(to: Routes.user_path(conn, :forgot_password))
    else
      {:ok, user} ->
        pwd = random_string()

        case Accounts.update_user(user, %{password: pwd, auto_password: "Y"}) do
          {:ok, _user} ->
            Email.password_alert(user.email, pwd)

            conn
            |> put_flash(:info, "Success...Check your email")
            |> redirect(to: Routes.session_path(conn, :new))

          {:error, _reason} ->
            conn
            |> put_flash(:error, "An error occured, try again!")
            |> redirect(to: Routes.user_path(conn, :forgot_password))
        end
    end
  end

  def change_user_status(conn, %{"id" => id, "status" => status}) do
    perform_status_change(conn, id, status)
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        json(conn, %{info: "changes made successfully!"})

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        json(conn, %{error: reason})
    end
  end

  def perform_status_change(conn, id, status) do
    user = Accounts.get_user!(id)
    changeset = User.changeset(user, %{status: status, checker_id: conn.assigns.user.id})

    activity = """
    changed user  status: Email: #{user.email},
    New status: #{status}, Firstname: #{user.first_name}
    """

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, changeset)
    |> Ecto.Multi.insert(
      :insert,
      UserLog.changeset(
        %UserLog{},
        %{user_id: conn.assigns.user.id, activity: activity}
      )
    )
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    roles = Accounts.list_tbl_user_role() |> Enum.reject(&(&1.status != "A"))
    page = %{first: "Users", last: "Edit"}
    render(conn, "edit.html", user_rec: user, page: page, roles: roles)
  end

  def update(conn, user_params) do
    user = Accounts.get_user!(user_params["id"])

    perform_update(conn, user, user_params)
    |> Repo.transaction()
    |> case do
      {:ok, %{update: _update, insert: _insert}} ->
        conn
        |> put_flash(:info, "Changes applied successfully!")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.user_path(conn, :index))
    end
  end

  def perform_update(conn, user, user_params) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:update, User.changeset(user, user_params))
    |> Ecto.Multi.run(:insert, fn repo, %{update: user} ->
      activity = "Updated user: Email: #{user.email} and First Name: #{user.first_name}"

      userlog = %{
        user_id: conn.assigns.user.id,
        activity: activity
      }

      UserLog.changeset(%UserLog{}, userlog)
      |> repo.insert()
    end)
  end

  def create(conn, user_params) do
    pwd = random_string()
    user_params = Map.put(user_params, "password", pwd)
    expiry_days = Rms.SystemUtilities.list_company_info().password_expiry_days
    pwd_days = Timex.shift(Timex.today(), days: expiry_days)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(
      :user,
      User.changeset(
        %User{maker_id: conn.assigns.user.id, password_expiry_dt: pwd_days},
        user_params
      )
    )
    |> Ecto.Multi.run(:userlog, fn repo, %{user: user} ->
      activity = "Created new user with Email \"#{user.email}\" and username #{user.username}\""

      UserLog.changeset(%UserLog{}, %{
        user_id: conn.assigns.user.id,
        activity: activity
      })
      |> repo.insert()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user, userlog: _userlog}} ->
        Email.send_login_details(user.email, pwd)

        conn
        |> put_flash(:info, "#{String.capitalize(user.first_name)} created successfully.")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, _failed_operation, failed_value, _changes_so_far} ->
        reason = traverse_errors(failed_value.errors) |> List.first()

        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.user_path(conn, :index))
    end
  catch
    _error, error ->
      Logger.error(IO.inspect(Exception.format(:error, error, __STACKTRACE__)))

      conn
      |> put_flash(:error, "An error occurred, reason unknown. try again")
      |> redirect(to: Routes.user_path(conn, :index))
  end

  def user_logs(conn, %{"id" => user_id}) do
    with :error <- confirm_token(conn, user_id) do
      conn
      |> put_flash(:error, "invalid token received")
      |> redirect(to: Routes.user_path(conn, :index))
    else
      {:ok, user} ->
        user_logs = Rms.Activity.get_logs_by(user.id)
        render(conn, "activity_logs.html", user_logs: user_logs)
    end
  end

  def number do
    spec = Enum.to_list(?2..?9)
    length = 2
    Enum.take_random(spec, length)
  end

  def number2 do
    spec = Enum.to_list(?1..?9)
    length = 1
    Enum.take_random(spec, length)
  end

  def caplock do
    spec = Enum.to_list(?A..?N)
    length = 1
    Enum.take_random(spec, length)
  end

  def small_latter do
    spec = Enum.to_list(?a..?n)
    length = 1
    Enum.take_random(spec, length)
  end

  def small_latter2 do
    spec = Enum.to_list(?p..?z)
    length = 2
    Enum.take_random(spec, length)
  end

  def special do
    spec = Enum.to_list(?#..?*)
    length = 1

    Enum.take_random(spec, length)
    |> to_string()
    |> String.replace("'", "^")
    |> String.replace("(", "!")
    |> String.replace(")", "@")
  end

  def random_string() do
    smll = to_string(small_latter())
    smll2 = to_string(small_latter2())
    nmb = to_string(number())
    nmb2 = to_string(number2())
    spc = to_string(special())
    cpl = to_string(caplock())
    smll <> "" <> nmb <> "" <> spc <> "" <> cpl <> "" <> nmb2 <> "" <> smll2
  end

  def create_userlog(id, activity) do
    {1, _} = Repo.insert_all("tbl_user_activity", userlog(id, activity))
  end

  defp userlog(id, activity) do
    [
      %{
        user_id: id,
        activity: activity,
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      }
    ]
  end

  def get_user_by(username) do
    case Repo.get_by(User, username: username) do
      nil -> {:error, "invalid email/password"}
      user -> {:ok, user}
    end
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  def traverse_errors(errors) do
    for {key, {msg, _opts}} <- errors, do: "#{key} #{msg}"
  end

  def authorize(conn) do
    case Phoenix.Controller.action_name(conn) do
      act when act in ~w(new create)a -> {:user, :create}
      act when act in ~w(index)a -> {:user, :index}
      act when act in ~w(update edit)a -> {:user, :edit}
      act when act in ~w(change_user_status)a -> {:user, :change_status}
      act when act in ~w(delete)a -> {:user, :delete}
      _ -> {:user, :unknown}
    end
  end
end

# plug(CtsWeb.Plugs.RequireAdminAccess when action not in [:new_password, :change_password, :dashboard, :user_logs])
# plug(CtsWeb.Plugs.RequireMakerAuth when action in [:new, :edit, :create, :update])
# plug(CtsWeb.Plugs.RequireCheckerAuth when action in [:change_user_status])
