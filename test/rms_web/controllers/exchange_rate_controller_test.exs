defmodule RmsWeb.ExchangeRateControllerTest do
  use RmsWeb.ConnCase

  alias Rms.ExchangeRates

  @create_attrs %{
    currency_code: "some currency_code",
    exchange_rate: "some exchange_rate",
    start_date: "some start_date",
    symbol: "some symbol"
  }
  @update_attrs %{
    currency_code: "some updated currency_code",
    exchange_rate: "some updated exchange_rate",
    start_date: "some updated start_date",
    symbol: "some updated symbol"
  }
  @invalid_attrs %{currency_code: nil, exchange_rate: nil, start_date: nil, symbol: nil}

  def fixture(:exchange_rate) do
    {:ok, exchange_rate} = ExchangeRates.create_exchange_rate(@create_attrs)
    exchange_rate
  end

  describe "index" do
    test "lists all tbl_exchange_rate", %{conn: conn} do
      conn = get(conn, Routes.exchange_rate_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl exchange rate"
    end
  end

  describe "new exchange_rate" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.exchange_rate_path(conn, :new))
      assert html_response(conn, 200) =~ "New Exchange rate"
    end
  end

  describe "create exchange_rate" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.exchange_rate_path(conn, :create), exchange_rate: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.exchange_rate_path(conn, :show, id)

      conn = get(conn, Routes.exchange_rate_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Exchange rate"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.exchange_rate_path(conn, :create), exchange_rate: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Exchange rate"
    end
  end

  describe "edit exchange_rate" do
    setup [:create_exchange_rate]

    test "renders form for editing chosen exchange_rate", %{
      conn: conn,
      exchange_rate: exchange_rate
    } do
      conn = get(conn, Routes.exchange_rate_path(conn, :edit, exchange_rate))
      assert html_response(conn, 200) =~ "Edit Exchange rate"
    end
  end

  describe "update exchange_rate" do
    setup [:create_exchange_rate]

    test "redirects when data is valid", %{conn: conn, exchange_rate: exchange_rate} do
      conn =
        put(conn, Routes.exchange_rate_path(conn, :update, exchange_rate),
          exchange_rate: @update_attrs
        )

      assert redirected_to(conn) == Routes.exchange_rate_path(conn, :show, exchange_rate)

      conn = get(conn, Routes.exchange_rate_path(conn, :show, exchange_rate))
      assert html_response(conn, 200) =~ "some updated currency_code"
    end

    test "renders errors when data is invalid", %{conn: conn, exchange_rate: exchange_rate} do
      conn =
        put(conn, Routes.exchange_rate_path(conn, :update, exchange_rate),
          exchange_rate: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Exchange rate"
    end
  end

  describe "delete exchange_rate" do
    setup [:create_exchange_rate]

    test "deletes chosen exchange_rate", %{conn: conn, exchange_rate: exchange_rate} do
      conn = delete(conn, Routes.exchange_rate_path(conn, :delete, exchange_rate))
      assert redirected_to(conn) == Routes.exchange_rate_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.exchange_rate_path(conn, :show, exchange_rate))
      end
    end
  end

  defp create_exchange_rate(_) do
    exchange_rate = fixture(:exchange_rate)
    %{exchange_rate: exchange_rate}
  end
end
