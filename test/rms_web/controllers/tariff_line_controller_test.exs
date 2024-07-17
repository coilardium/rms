defmodule RmsWeb.TariffLineControllerTest do
  use RmsWeb.ConnCase

  alias Rms.TariffLines

  @create_attrs %{
    active_from: "some active_from",
    client: "some client",
    commodity: "some commodity",
    currency: "some currency",
    destination: "some destination",
    nll_2005: 120.5,
    nlpi: 120.5,
    origin: "some origin",
    others: 120.5,
    payment_type: "some payment_type",
    rsz: 120.5,
    surcharge: "some surcharge",
    tfr: 120.5,
    total: 120.5,
    tzr: 120.5,
    tzr_project: 120.5
  }
  @update_attrs %{
    active_from: "some updated active_from",
    client: "some updated client",
    commodity: "some updated commodity",
    currency: "some updated currency",
    destination: "some updated destination",
    nll_2005: 456.7,
    nlpi: 456.7,
    origin: "some updated origin",
    others: 456.7,
    payment_type: "some updated payment_type",
    rsz: 456.7,
    surcharge: "some updated surcharge",
    tfr: 456.7,
    total: 456.7,
    tzr: 456.7,
    tzr_project: 456.7
  }
  @invalid_attrs %{
    active_from: nil,
    client: nil,
    commodity: nil,
    currency: nil,
    destination: nil,
    nll_2005: nil,
    nlpi: nil,
    origin: nil,
    others: nil,
    payment_type: nil,
    rsz: nil,
    surcharge: nil,
    tfr: nil,
    total: nil,
    tzr: nil,
    tzr_project: nil
  }

  def fixture(:tariff_line) do
    {:ok, tariff_line} = TariffLines.create_tariff_line(@create_attrs)
    tariff_line
  end

  describe "index" do
    test "lists all tbl_tariff_line", %{conn: conn} do
      conn = get(conn, Routes.tariff_line_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl tariff line"
    end
  end

  describe "new tariff_line" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.tariff_line_path(conn, :new))
      assert html_response(conn, 200) =~ "New Tariff line"
    end
  end

  describe "create tariff_line" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tariff_line_path(conn, :create), tariff_line: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.tariff_line_path(conn, :show, id)

      conn = get(conn, Routes.tariff_line_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Tariff line"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.tariff_line_path(conn, :create), tariff_line: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tariff line"
    end
  end

  describe "edit tariff_line" do
    setup [:create_tariff_line]

    test "renders form for editing chosen tariff_line", %{conn: conn, tariff_line: tariff_line} do
      conn = get(conn, Routes.tariff_line_path(conn, :edit, tariff_line))
      assert html_response(conn, 200) =~ "Edit Tariff line"
    end
  end

  describe "update tariff_line" do
    setup [:create_tariff_line]

    test "redirects when data is valid", %{conn: conn, tariff_line: tariff_line} do
      conn =
        put(conn, Routes.tariff_line_path(conn, :update, tariff_line), tariff_line: @update_attrs)

      assert redirected_to(conn) == Routes.tariff_line_path(conn, :show, tariff_line)

      conn = get(conn, Routes.tariff_line_path(conn, :show, tariff_line))
      assert html_response(conn, 200) =~ "some updated active_from"
    end

    test "renders errors when data is invalid", %{conn: conn, tariff_line: tariff_line} do
      conn =
        put(conn, Routes.tariff_line_path(conn, :update, tariff_line), tariff_line: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Tariff line"
    end
  end

  describe "delete tariff_line" do
    setup [:create_tariff_line]

    test "deletes chosen tariff_line", %{conn: conn, tariff_line: tariff_line} do
      conn = delete(conn, Routes.tariff_line_path(conn, :delete, tariff_line))
      assert redirected_to(conn) == Routes.tariff_line_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.tariff_line_path(conn, :show, tariff_line))
      end
    end
  end

  defp create_tariff_line(_) do
    tariff_line = fixture(:tariff_line)
    %{tariff_line: tariff_line}
  end
end
