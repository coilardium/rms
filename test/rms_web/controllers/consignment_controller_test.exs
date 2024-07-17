defmodule RmsWeb.ConsignmentControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Consignments

  @create_attrs %{
    capture_date: "some capture_date",
    code: "some code",
    commodity: "some commodity",
    consignee: "some consignee",
    consigner: "some consigner",
    customer: "some customer",
    customer_ref: "some customer_ref",
    document_date: "some document_date",
    final_destination: "some final_destination",
    origin_station: "some origin_station",
    payer: "some payer",
    reporting_station: "some reporting_station",
    sale_order: "some sale_order",
    station_code: "some station_code",
    status: "some status",
    tariff_destination: "some tariff_destination",
    tariff_origin: "some tariff_origin"
  }
  @update_attrs %{
    capture_date: "some updated capture_date",
    code: "some updated code",
    commodity: "some updated commodity",
    consignee: "some updated consignee",
    consigner: "some updated consigner",
    customer: "some updated customer",
    customer_ref: "some updated customer_ref",
    document_date: "some updated document_date",
    final_destination: "some updated final_destination",
    origin_station: "some updated origin_station",
    payer: "some updated payer",
    reporting_station: "some updated reporting_station",
    sale_order: "some updated sale_order",
    station_code: "some updated station_code",
    status: "some updated status",
    tariff_destination: "some updated tariff_destination",
    tariff_origin: "some updated tariff_origin"
  }
  @invalid_attrs %{
    capture_date: nil,
    code: nil,
    commodity: nil,
    consignee: nil,
    consigner: nil,
    customer: nil,
    customer_ref: nil,
    document_date: nil,
    final_destination: nil,
    origin_station: nil,
    payer: nil,
    reporting_station: nil,
    sale_order: nil,
    station_code: nil,
    status: nil,
    tariff_destination: nil,
    tariff_origin: nil
  }

  def fixture(:consignment) do
    {:ok, consignment} = Consignments.create_consignment(@create_attrs)
    consignment
  end

  describe "index" do
    test "lists all tbl_consignments", %{conn: conn} do
      conn = get(conn, Routes.consignment_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl consignments"
    end
  end

  describe "new consignment" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.consignment_path(conn, :new))
      assert html_response(conn, 200) =~ "New Consignment"
    end
  end

  describe "create consignment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.consignment_path(conn, :create), consignment: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.consignment_path(conn, :show, id)

      conn = get(conn, Routes.consignment_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Consignment"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.consignment_path(conn, :create), consignment: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Consignment"
    end
  end

  describe "edit consignment" do
    setup [:create_consignment]

    test "renders form for editing chosen consignment", %{conn: conn, consignment: consignment} do
      conn = get(conn, Routes.consignment_path(conn, :edit, consignment))
      assert html_response(conn, 200) =~ "Edit Consignment"
    end
  end

  describe "update consignment" do
    setup [:create_consignment]

    test "redirects when data is valid", %{conn: conn, consignment: consignment} do
      conn =
        put(conn, Routes.consignment_path(conn, :update, consignment), consignment: @update_attrs)

      assert redirected_to(conn) == Routes.consignment_path(conn, :show, consignment)

      conn = get(conn, Routes.consignment_path(conn, :show, consignment))
      assert html_response(conn, 200) =~ "some updated capture_date"
    end

    test "renders errors when data is invalid", %{conn: conn, consignment: consignment} do
      conn =
        put(conn, Routes.consignment_path(conn, :update, consignment), consignment: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Consignment"
    end
  end

  describe "delete consignment" do
    setup [:create_consignment]

    test "deletes chosen consignment", %{conn: conn, consignment: consignment} do
      conn = delete(conn, Routes.consignment_path(conn, :delete, consignment))
      assert redirected_to(conn) == Routes.consignment_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.consignment_path(conn, :show, consignment))
      end
    end
  end

  defp create_consignment(_) do
    consignment = fixture(:consignment)
    %{consignment: consignment}
  end
end
