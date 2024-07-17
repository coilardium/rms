defmodule RmsWeb.Plugs.Authenticate do
  @behaviour Plug
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias Rms.Accounts

  def init(params), do: params

  def call(conn, opts) do
    user_id = get_session(conn, :current_user)
    user = user_id && Accounts.get_user!(user_id)
    callback = opts[:module_callback]
    role = Accounts.get_user_role!(user.role_id)
    {module, action} = callback.(conn)

    cond do
      get_in(user_role(role), [module, action]) == "Y" and user.status == "A" and
          role.status == "A" ->
        conn

      true ->
        conn
        |> put_flash(:error, "Access denied!!!")
        |> redirect(to: RmsWeb.Router.Helpers.session_path(conn, :new))
        |> halt()
    end
  end

  defp user_role(role) do
    role
    |> Map.get(:role_str)
    |> AtomicMap.convert(%{safe: false})
  end
end
