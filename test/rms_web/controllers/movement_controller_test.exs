defmodule RmsWeb.MovementControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Order

  @create_attrs %{
    commodity_id: "some commodity_id",
    consignee: "some consignee",
    consigner: "some consigner",
    consignment_date: "some consignment_date",
    container_no: "some container_no",
    dead_loco: "some dead_loco",
    destin_station_id: "some destin_station_id",
    destination: "some destination",
    loco_id: "some loco_id",
    movement_date: "some movement_date",
    movement_time: "some movement_time",
    netweight: "some netweight",
    orgin_station_id: "some orgin_station_id",
    origin: "some origin",
    payer_id: "some payer_id",
    reporting_station: "some reporting_station",
    sales_order: "some sales_order",
    station_code: "some station_code",
    train_no: "some train_no",
    wagon_id: "some wagon_id"
  }
  @update_attrs %{
    commodity_id: "some updated commodity_id",
    consignee: "some updated consignee",
    consigner: "some updated consigner",
    consignment_date: "some updated consignment_date",
    container_no: "some updated container_no",
    dead_loco: "some updated dead_loco",
    destin_station_id: "some updated destin_station_id",
    destination: "some updated destination",
    loco_id: "some updated loco_id",
    movement_date: "some updated movement_date",
    movement_time: "some updated movement_time",
    netweight: "some updated netweight",
    orgin_station_id: "some updated orgin_station_id",
    origin: "some updated origin",
    payer_id: "some updated payer_id",
    reporting_station: "some updated reporting_station",
    sales_order: "some updated sales_order",
    station_code: "some updated station_code",
    train_no: "some updated train_no",
    wagon_id: "some updated wagon_id"
  }
  @invalid_attrs %{
    commodity_id: nil,
    consignee: nil,
    consigner: nil,
    consignment_date: nil,
    container_no: nil,
    dead_loco: nil,
    destin_station_id: nil,
    destination: nil,
    loco_id: nil,
    movement_date: nil,
    movement_time: nil,
    netweight: nil,
    orgin_station_id: nil,
    origin: nil,
    payer_id: nil,
    reporting_station: nil,
    sales_order: nil,
    station_code: nil,
    train_no: nil,
    wagon_id: nil
  }

  def fixture(:movement) do
    {:ok, movement} = Order.create_movement(@create_attrs)
    movement
  end

  describe "index" do
    test "lists all tbl_movement", %{conn: conn} do
      conn = get(conn, Routes.movement_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl movement"
    end
  end

  describe "new movement" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.movement_path(conn, :new))
      assert html_response(conn, 200) =~ "New Movement"
    end
  end

  describe "create movement" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.movement_path(conn, :create), movement: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.movement_path(conn, :show, id)

      conn = get(conn, Routes.movement_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Movement"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.movement_path(conn, :create), movement: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Movement"
    end
  end

  describe "edit movement" do
    setup [:create_movement]

    test "renders form for editing chosen movement", %{conn: conn, movement: movement} do
      conn = get(conn, Routes.movement_path(conn, :edit, movement))
      assert html_response(conn, 200) =~ "Edit Movement"
    end
  end

  describe "update movement" do
    setup [:create_movement]

    test "redirects when data is valid", %{conn: conn, movement: movement} do
      conn = put(conn, Routes.movement_path(conn, :update, movement), movement: @update_attrs)
      assert redirected_to(conn) == Routes.movement_path(conn, :show, movement)

      conn = get(conn, Routes.movement_path(conn, :show, movement))
      assert html_response(conn, 200) =~ "some updated commodity_id"
    end

    test "renders errors when data is invalid", %{conn: conn, movement: movement} do
      conn = put(conn, Routes.movement_path(conn, :update, movement), movement: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Movement"
    end
  end

  describe "delete movement" do
    setup [:create_movement]

    test "deletes chosen movement", %{conn: conn, movement: movement} do
      conn = delete(conn, Routes.movement_path(conn, :delete, movement))
      assert redirected_to(conn) == Routes.movement_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.movement_path(conn, :show, movement))
      end
    end
  end

  defp create_movement(_) do
    movement = fixture(:movement)
    %{movement: movement}
  end
end
