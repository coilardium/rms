defmodule RmsWeb.RatesControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Fuel

  @create_attrs %{
    code: "some code",
    fuel_rate: "some fuel_rate",
    month: "some month",
    refueling_depo: "some refueling_depo",
    status: "some status"
  }
  @update_attrs %{
    code: "some updated code",
    fuel_rate: "some updated fuel_rate",
    month: "some updated month",
    refueling_depo: "some updated refueling_depo",
    status: "some updated status"
  }
  @invalid_attrs %{code: nil, fuel_rate: nil, month: nil, refueling_depo: nil, status: nil}

  def fixture(:rates) do
    {:ok, rates} = Fuel.create_rates(@create_attrs)
    rates
  end

  describe "index" do
    test "lists all tbl_fuel_rates", %{conn: conn} do
      conn = get(conn, Routes.rates_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl fuel rates"
    end
  end

  describe "new rates" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.rates_path(conn, :new))
      assert html_response(conn, 200) =~ "New Rates"
    end
  end

  describe "create rates" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.rates_path(conn, :create), rates: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.rates_path(conn, :show, id)

      conn = get(conn, Routes.rates_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Rates"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.rates_path(conn, :create), rates: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Rates"
    end
  end

  describe "edit rates" do
    setup [:create_rates]

    test "renders form for editing chosen rates", %{conn: conn, rates: rates} do
      conn = get(conn, Routes.rates_path(conn, :edit, rates))
      assert html_response(conn, 200) =~ "Edit Rates"
    end
  end

  describe "update rates" do
    setup [:create_rates]

    test "redirects when data is valid", %{conn: conn, rates: rates} do
      conn = put(conn, Routes.rates_path(conn, :update, rates), rates: @update_attrs)
      assert redirected_to(conn) == Routes.rates_path(conn, :show, rates)

      conn = get(conn, Routes.rates_path(conn, :show, rates))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, rates: rates} do
      conn = put(conn, Routes.rates_path(conn, :update, rates), rates: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Rates"
    end
  end

  describe "delete rates" do
    setup [:create_rates]

    test "deletes chosen rates", %{conn: conn, rates: rates} do
      conn = delete(conn, Routes.rates_path(conn, :delete, rates))
      assert redirected_to(conn) == Routes.rates_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.rates_path(conn, :show, rates))
      end
    end
  end

  defp create_rates(_) do
    rates = fixture(:rates)
    %{rates: rates}
  end
end
