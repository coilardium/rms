defmodule RmsWeb.ClientsControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Customers

  @create_attrs %{
    address: "some address",
    client_account: "some client_account",
    client_name: "some client_name",
    email: "some email",
    phone_number: "some phone_number",
    status: "some status"
  }
  @update_attrs %{
    address: "some updated address",
    client_account: "some updated client_account",
    client_name: "some updated client_name",
    email: "some updated email",
    phone_number: "some updated phone_number",
    status: "some updated status"
  }
  @invalid_attrs %{
    address: nil,
    client_account: nil,
    client_name: nil,
    email: nil,
    phone_number: nil,
    status: nil
  }

  def fixture(:clients) do
    {:ok, clients} = Customers.create_clients(@create_attrs)
    clients
  end

  describe "index" do
    test "lists all tbl_clients", %{conn: conn} do
      conn = get(conn, Routes.clients_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl clients"
    end
  end

  describe "new clients" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.clients_path(conn, :new))
      assert html_response(conn, 200) =~ "New Clients"
    end
  end

  describe "create clients" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.clients_path(conn, :create), clients: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.clients_path(conn, :show, id)

      conn = get(conn, Routes.clients_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Clients"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.clients_path(conn, :create), clients: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Clients"
    end
  end

  describe "edit clients" do
    setup [:create_clients]

    test "renders form for editing chosen clients", %{conn: conn, clients: clients} do
      conn = get(conn, Routes.clients_path(conn, :edit, clients))
      assert html_response(conn, 200) =~ "Edit Clients"
    end
  end

  describe "update clients" do
    setup [:create_clients]

    test "redirects when data is valid", %{conn: conn, clients: clients} do
      conn = put(conn, Routes.clients_path(conn, :update, clients), clients: @update_attrs)
      assert redirected_to(conn) == Routes.clients_path(conn, :show, clients)

      conn = get(conn, Routes.clients_path(conn, :show, clients))
      assert html_response(conn, 200) =~ "some updated address"
    end

    test "renders errors when data is invalid", %{conn: conn, clients: clients} do
      conn = put(conn, Routes.clients_path(conn, :update, clients), clients: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Clients"
    end
  end

  describe "delete clients" do
    setup [:create_clients]

    test "deletes chosen clients", %{conn: conn, clients: clients} do
      conn = delete(conn, Routes.clients_path(conn, :delete, clients))
      assert redirected_to(conn) == Routes.clients_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.clients_path(conn, :show, clients))
      end
    end
  end

  defp create_clients(_) do
    clients = fixture(:clients)
    %{clients: clients}
  end
end
