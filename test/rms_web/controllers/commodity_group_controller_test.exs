defmodule RmsWeb.CommodityGroupControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Commodities

  @create_attrs %{code: "some code", description: "some description", status: "some status"}
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    status: "some updated status"
  }
  @invalid_attrs %{code: nil, description: nil, status: nil}

  def fixture(:commodity_group) do
    {:ok, commodity_group} = Commodities.create_commodity_group(@create_attrs)
    commodity_group
  end

  describe "index" do
    test "lists all tbl_commodity_group", %{conn: conn} do
      conn = get(conn, Routes.commodity_group_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl commodity group"
    end
  end

  describe "new commodity_group" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.commodity_group_path(conn, :new))
      assert html_response(conn, 200) =~ "New Commodity group"
    end
  end

  describe "create commodity_group" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.commodity_group_path(conn, :create), commodity_group: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.commodity_group_path(conn, :show, id)

      conn = get(conn, Routes.commodity_group_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Commodity group"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.commodity_group_path(conn, :create), commodity_group: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Commodity group"
    end
  end

  describe "edit commodity_group" do
    setup [:create_commodity_group]

    test "renders form for editing chosen commodity_group", %{
      conn: conn,
      commodity_group: commodity_group
    } do
      conn = get(conn, Routes.commodity_group_path(conn, :edit, commodity_group))
      assert html_response(conn, 200) =~ "Edit Commodity group"
    end
  end

  describe "update commodity_group" do
    setup [:create_commodity_group]

    test "redirects when data is valid", %{conn: conn, commodity_group: commodity_group} do
      conn =
        put(conn, Routes.commodity_group_path(conn, :update, commodity_group),
          commodity_group: @update_attrs
        )

      assert redirected_to(conn) == Routes.commodity_group_path(conn, :show, commodity_group)

      conn = get(conn, Routes.commodity_group_path(conn, :show, commodity_group))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, commodity_group: commodity_group} do
      conn =
        put(conn, Routes.commodity_group_path(conn, :update, commodity_group),
          commodity_group: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Commodity group"
    end
  end

  describe "delete commodity_group" do
    setup [:create_commodity_group]

    test "deletes chosen commodity_group", %{conn: conn, commodity_group: commodity_group} do
      conn = delete(conn, Routes.commodity_group_path(conn, :delete, commodity_group))
      assert redirected_to(conn) == Routes.commodity_group_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.commodity_group_path(conn, :show, commodity_group))
      end
    end
  end

  defp create_commodity_group(_) do
    commodity_group = fixture(:commodity_group)
    %{commodity_group: commodity_group}
  end
end
