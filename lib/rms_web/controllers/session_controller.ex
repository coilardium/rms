defmodule RmsWeb.SessionController do
  use RmsWeb, :controller
  require Logger
  # alias RmsWeb.UserController
  alias Rms.Accounts
  alias RmsWeb.UserController
  alias Rms.Auth
  alias Auth

  plug(
    RmsWeb.Plugs.RequireAuth
    when action in [:signout]
  )

  def new(conn, _params) do
    put_layout(conn, false)
    |> render("index.html")
  end

  def create(conn, params) do
    with {:error, _reason} <- UserController.get_user_by_email(String.trim(params["email"])) do
      conn
      |> put_flash(:error, "Email/password not match")
      |> put_layout(false)
      |> render("index.html")
    else
      {:ok, user} ->
        with {:error, _reason} <- Auth.confirm_password(user, String.trim(params["password"])) do
          prepare_login_attempt(user)

          conn
          |> put_flash(:error, "Email/password not match")
          |> put_layout(false)
          |> render("index.html")
        else
          {:ok, _} ->
            cond do
              user.status == "A" ->
                {:ok, _} =
                  Rms.Activity.create_user_log(%{user_id: user.id, activity: "logged in"})

                logon_dt = Timex.format!(Timex.local(), "%Y-%m-%d %H:%M:%S", :strftime)
                remote_ip = conn.remote_ip |> :inet.ntoa() |> to_string()

                {:ok, user} =
                  Accounts.update_user(user, %{
                    remote_ip: remote_ip,
                    last_login_dt: logon_dt,
                    login_attempt: 0
                  })

                conn
                |> put_session(:current_user, user.id)
                |> put_session(:session_timeout_at, session_timeout_at())
                |> redirect(to: Routes.user_path(conn, :dashboard))

              user.status != "A" ->
                conn
                |> put_flash(:error, "Account blocked. Contact system admin")
                |> clear_session()
                |> redirect(to: Routes.session_path(conn, :new))

              true ->
                conn
                |> put_status(405)
                |> put_layout(false)
                |> render("index.html")
            end
        end
    end
  end

  defp session_timeout_at do
    DateTime.utc_now() |> DateTime.to_unix() |> (&(&1 + 10_000)).()
  end

  def signout(conn, _params) do
    {:ok, _} =
      Rms.Activity.create_user_log(%{user_id: conn.assigns.user.id, activity: "logged out"})

    conn
    # |> configure_session(drop: true)
    |> clear_session()
    |> redirect(to: Routes.session_path(conn, :new))
  rescue
    _ ->
      conn
      # |> configure_session(drop: true)
      |> clear_session()
      |> redirect(to: Routes.session_path(conn, :new))
  end

  defp prepare_login_attempt(user) do
    max_attempts = Rms.SystemUtilities.list_company_info().login_attempts
    status = if user.login_attempt < max_attempts, do: "A", else: "D"
    Accounts.update_user(user, %{login_attempt: user.login_attempt + 1, status: status})
  end
end
