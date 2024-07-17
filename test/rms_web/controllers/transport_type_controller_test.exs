defmodule RmsWeb.TransportTypeControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Transport

  @create_attrs %{
    code: "some code",
    description: "some description",
    status: "some status",
    transport_type: "some transport_type"
  }
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    status: "some updated status",
    transport_type: "some updated transport_type"
  }
  @invalid_attrs %{code: nil, description: nil, status: nil, transport_type: nil}

  def fixture(:transport_type) do
    {:ok, transport_type} = Transport.create_transport_type(@create_attrs)
    transport_type
  end

  describe "index" do
    test "lists all tbl_transport_type", %{conn: conn} do
      conn = get(conn, Routes.transport_type_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl transport type"
    end
  end

  describe "new transport_type" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.transport_type_path(conn, :new))
      assert html_response(conn, 200) =~ "New Transport type"
    end
  end

  describe "create transport_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.transport_type_path(conn, :create), transport_type: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.transport_type_path(conn, :show, id)

      conn = get(conn, Routes.transport_type_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Transport type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.transport_type_path(conn, :create), transport_type: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Transport type"
    end
  end

  describe "edit transport_type" do
    setup [:create_transport_type]

    test "renders form for editing chosen transport_type", %{
      conn: conn,
      transport_type: transport_type
    } do
      conn = get(conn, Routes.transport_type_path(conn, :edit, transport_type))
      assert html_response(conn, 200) =~ "Edit Transport type"
    end
  end

  describe "update transport_type" do
    setup [:create_transport_type]

    test "redirects when data is valid", %{conn: conn, transport_type: transport_type} do
      conn =
        put(conn, Routes.transport_type_path(conn, :update, transport_type),
          transport_type: @update_attrs
        )

      assert redirected_to(conn) == Routes.transport_type_path(conn, :show, transport_type)

      conn = get(conn, Routes.transport_type_path(conn, :show, transport_type))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, transport_type: transport_type} do
      conn =
        put(conn, Routes.transport_type_path(conn, :update, transport_type),
          transport_type: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Transport type"
    end
  end

  describe "delete transport_type" do
    setup [:create_transport_type]

    test "deletes chosen transport_type", %{conn: conn, transport_type: transport_type} do
      conn = delete(conn, Routes.transport_type_path(conn, :delete, transport_type))
      assert redirected_to(conn) == Routes.transport_type_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.transport_type_path(conn, :show, transport_type))
      end
    end
  end

  defp create_transport_type(_) do
    transport_type = fixture(:transport_type)
    %{transport_type: transport_type}
  end
end
