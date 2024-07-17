defmodule RmsWeb.Plugs.EnforcePasswordPolicy do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias Rms.Accounts

  def init(_params) do
  end

  def call(conn, _params) do
    user_id = get_session(conn, :current_user) || get_session(conn, :current_client)
    user = user_id && Accounts.get_user!(user_id)

    cond do
      is_nil(user) == false and
        Timex.diff(user.password_expiry_dt, Timex.today(), :hours) > 1 == true and
          user.auto_password != "Y" ->
        conn

      true ->
        conn
        |> put_flash(:error, "Password reset is required!")
        |> redirect(to: RmsWeb.Router.Helpers.user_path(conn, :new_password))
        |> halt()
    end
  end
end
