defmodule RmsWeb.CommodityControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Commodities

  @create_attrs %{
    code: "some code",
    commodity_group: "some commodity_group",
    description: "some description",
    is_container: "some is_container",
    status: "some status"
  }
  @update_attrs %{
    code: "some updated code",
    commodity_group: "some updated commodity_group",
    description: "some updated description",
    is_container: "some updated is_container",
    status: "some updated status"
  }
  @invalid_attrs %{
    code: nil,
    commodity_group: nil,
    description: nil,
    is_container: nil,
    status: nil
  }

  def fixture(:commodity) do
    {:ok, commodity} = Commodities.create_commodity(@create_attrs)
    commodity
  end

  describe "index" do
    test "lists all tbl_commodity", %{conn: conn} do
      conn = get(conn, Routes.commodity_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl commodity"
    end
  end

  describe "new commodity" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.commodity_path(conn, :new))
      assert html_response(conn, 200) =~ "New Commodity"
    end
  end

  describe "create commodity" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.commodity_path(conn, :create), commodity: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.commodity_path(conn, :show, id)

      conn = get(conn, Routes.commodity_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Commodity"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.commodity_path(conn, :create), commodity: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Commodity"
    end
  end

  describe "edit commodity" do
    setup [:create_commodity]

    test "renders form for editing chosen commodity", %{conn: conn, commodity: commodity} do
      conn = get(conn, Routes.commodity_path(conn, :edit, commodity))
      assert html_response(conn, 200) =~ "Edit Commodity"
    end
  end

  describe "update commodity" do
    setup [:create_commodity]

    test "redirects when data is valid", %{conn: conn, commodity: commodity} do
      conn = put(conn, Routes.commodity_path(conn, :update, commodity), commodity: @update_attrs)
      assert redirected_to(conn) == Routes.commodity_path(conn, :show, commodity)

      conn = get(conn, Routes.commodity_path(conn, :show, commodity))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, commodity: commodity} do
      conn = put(conn, Routes.commodity_path(conn, :update, commodity), commodity: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Commodity"
    end
  end

  describe "delete commodity" do
    setup [:create_commodity]

    test "deletes chosen commodity", %{conn: conn, commodity: commodity} do
      conn = delete(conn, Routes.commodity_path(conn, :delete, commodity))
      assert redirected_to(conn) == Routes.commodity_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.commodity_path(conn, :show, commodity))
      end
    end
  end

  defp create_commodity(_) do
    commodity = fixture(:commodity)
    %{commodity: commodity}
  end
end
