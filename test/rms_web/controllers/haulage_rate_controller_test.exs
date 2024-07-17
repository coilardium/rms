defmodule RmsWeb.HaulageRateControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{
    distance: "120.5",
    rate: "120.5",
    rate_type: "some rate_type",
    start_date: ~D[2010-04-17],
    status: "some status"
  }
  @update_attrs %{
    distance: "456.7",
    rate: "456.7",
    rate_type: "some updated rate_type",
    start_date: ~D[2011-05-18],
    status: "some updated status"
  }
  @invalid_attrs %{distance: nil, rate: nil, rate_type: nil, start_date: nil, status: nil}

  def fixture(:haulage_rate) do
    {:ok, haulage_rate} = SystemUtilities.create_haulage_rate(@create_attrs)
    haulage_rate
  end

  describe "index" do
    test "lists all tbl_haulage_rates", %{conn: conn} do
      conn = get(conn, Routes.haulage_rate_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl hualage rates"
    end
  end

  describe "new haulage_rate" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.haulage_rate_path(conn, :new))
      assert html_response(conn, 200) =~ "New Haulage rate"
    end
  end

  describe "create haulage_rate" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.haulage_rate_path(conn, :create), haulage_rate: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.haulage_rate_path(conn, :show, id)

      conn = get(conn, Routes.haulage_rate_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Haulage rate"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.haulage_rate_path(conn, :create), haulage_rate: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Haulage rate"
    end
  end

  describe "edit haulage_rate" do
    setup [:create_haulage_rate]

    test "renders form for editing chosen haulage_rate", %{conn: conn, haulage_rate: haulage_rate} do
      conn = get(conn, Routes.haulage_rate_path(conn, :edit, haulage_rate))
      assert html_response(conn, 200) =~ "Edit Haulage rate"
    end
  end

  describe "update haulage_rate" do
    setup [:create_haulage_rate]

    test "redirects when data is valid", %{conn: conn, haulage_rate: haulage_rate} do
      conn =
        put(conn, Routes.haulage_rate_path(conn, :update, haulage_rate),
          haulage_rate: @update_attrs
        )

      assert redirected_to(conn) == Routes.haulage_rate_path(conn, :show, haulage_rate)

      conn = get(conn, Routes.haulage_rate_path(conn, :show, haulage_rate))
      assert html_response(conn, 200) =~ "some updated rate_type"
    end

    test "renders errors when data is invalid", %{conn: conn, haulage_rate: haulage_rate} do
      conn =
        put(conn, Routes.haulage_rate_path(conn, :update, haulage_rate),
          haulage_rate: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Haulage rate"
    end
  end

  describe "delete haulage_rate" do
    setup [:create_haulage_rate]

    test "deletes chosen haulage_rate", %{conn: conn, haulage_rate: haulage_rate} do
      conn = delete(conn, Routes.haulage_rate_path(conn, :delete, haulage_rate))
      assert redirected_to(conn) == Routes.haulage_rate_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.haulage_rate_path(conn, :show, haulage_rate))
      end
    end
  end

  defp create_haulage_rate(_) do
    haulage_rate = fixture(:haulage_rate)
    %{haulage_rate: haulage_rate}
  end
end
