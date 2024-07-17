defmodule RmsWeb.LocoDetentionRateControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{
    delay_charge: 42,
    rate: "120.5",
    start_date: ~D[2010-04-17],
    status: "some status"
  }
  @update_attrs %{
    delay_charge: 43,
    rate: "456.7",
    start_date: ~D[2011-05-18],
    status: "some updated status"
  }
  @invalid_attrs %{delay_charge: nil, rate: nil, start_date: nil, status: nil}

  def fixture(:loco_detention_rate) do
    {:ok, loco_detention_rate} = SystemUtilities.create_loco_detention_rate(@create_attrs)
    loco_detention_rate
  end

  describe "index" do
    test "lists all tbl_loco_dentention_rates", %{conn: conn} do
      conn = get(conn, Routes.loco_detention_rate_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl loco dentention rates"
    end
  end

  describe "new loco_detention_rate" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.loco_detention_rate_path(conn, :new))
      assert html_response(conn, 200) =~ "New Loco detention rate"
    end
  end

  describe "create loco_detention_rate" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.loco_detention_rate_path(conn, :create),
          loco_detention_rate: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.loco_detention_rate_path(conn, :show, id)

      conn = get(conn, Routes.loco_detention_rate_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Loco detention rate"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.loco_detention_rate_path(conn, :create),
          loco_detention_rate: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Loco detention rate"
    end
  end

  describe "edit loco_detention_rate" do
    setup [:create_loco_detention_rate]

    test "renders form for editing chosen loco_detention_rate", %{
      conn: conn,
      loco_detention_rate: loco_detention_rate
    } do
      conn = get(conn, Routes.loco_detention_rate_path(conn, :edit, loco_detention_rate))
      assert html_response(conn, 200) =~ "Edit Loco detention rate"
    end
  end

  describe "update loco_detention_rate" do
    setup [:create_loco_detention_rate]

    test "redirects when data is valid", %{conn: conn, loco_detention_rate: loco_detention_rate} do
      conn =
        put(conn, Routes.loco_detention_rate_path(conn, :update, loco_detention_rate),
          loco_detention_rate: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.loco_detention_rate_path(conn, :show, loco_detention_rate)

      conn = get(conn, Routes.loco_detention_rate_path(conn, :show, loco_detention_rate))
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      loco_detention_rate: loco_detention_rate
    } do
      conn =
        put(conn, Routes.loco_detention_rate_path(conn, :update, loco_detention_rate),
          loco_detention_rate: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Loco detention rate"
    end
  end

  describe "delete loco_detention_rate" do
    setup [:create_loco_detention_rate]

    test "deletes chosen loco_detention_rate", %{
      conn: conn,
      loco_detention_rate: loco_detention_rate
    } do
      conn = delete(conn, Routes.loco_detention_rate_path(conn, :delete, loco_detention_rate))
      assert redirected_to(conn) == Routes.loco_detention_rate_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.loco_detention_rate_path(conn, :show, loco_detention_rate))
      end
    end
  end

  defp create_loco_detention_rate(_) do
    loco_detention_rate = fixture(:loco_detention_rate)
    %{loco_detention_rate: loco_detention_rate}
  end
end
