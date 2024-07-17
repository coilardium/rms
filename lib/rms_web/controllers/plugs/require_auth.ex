defmodule RmsWeb.Plugs.RequireAuth do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias Rms.Accounts

  def init(_params) do
  end

  def call(conn, _params) do
    user_id = get_session(conn, :current_user)
    remote_ip = conn.remote_ip |> :inet.ntoa() |> to_string()

    if user_id do
      user = Accounts.get_user!(user_id)

      if(user.remote_ip == remote_ip and user.status == "A") do
        conn
      else
        conn
        # |> configure_session(drop: true)
        |> clear_session()
        |> put_flash(:error, "Session closed")
        |> redirect(to: RmsWeb.Router.Helpers.session_path(conn, :new))
        |> halt()
      end
    else
      conn
      |> put_flash(:error, "you must be logged in")
      |> redirect(to: RmsWeb.Router.Helpers.session_path(conn, :new))
      |> halt()
    end
  end
end
