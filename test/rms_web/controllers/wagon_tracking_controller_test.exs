defmodule RmsWeb.WagonTrackingControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Tracking

  @create_attrs %{
    allocated_to_customer: "some allocated_to_customer",
    arrival: "some arrival",
    bound: "some bound",
    comment: "some comment",
    departure: "some departure",
    hire: "some hire",
    net_ton: "120.5",
    sub_category: "some sub_category",
    train_no: "some train_no",
    update_date: ~D[2010-04-17],
    yard_siding: "some yard_siding"
  }
  @update_attrs %{
    allocated_to_customer: "some updated allocated_to_customer",
    arrival: "some updated arrival",
    bound: "some updated bound",
    comment: "some updated comment",
    departure: "some updated departure",
    hire: "some updated hire",
    net_ton: "456.7",
    sub_category: "some updated sub_category",
    train_no: "some updated train_no",
    update_date: ~D[2011-05-18],
    yard_siding: "some updated yard_siding"
  }
  @invalid_attrs %{
    allocated_to_customer: nil,
    arrival: nil,
    bound: nil,
    comment: nil,
    departure: nil,
    hire: nil,
    net_ton: nil,
    sub_category: nil,
    train_no: nil,
    update_date: nil,
    yard_siding: nil
  }

  def fixture(:wagon_tracking) do
    {:ok, wagon_tracking} = Tracking.create_wagon_tracking(@create_attrs)
    wagon_tracking
  end

  describe "index" do
    test "lists all tbl_wagon_tracking", %{conn: conn} do
      conn = get(conn, Routes.wagon_tracking_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl wagon tracking"
    end
  end

  describe "new wagon_tracking" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.wagon_tracking_path(conn, :new))
      assert html_response(conn, 200) =~ "New Wagon tracking"
    end
  end

  describe "create wagon_tracking" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.wagon_tracking_path(conn, :create), wagon_tracking: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.wagon_tracking_path(conn, :show, id)

      conn = get(conn, Routes.wagon_tracking_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Wagon tracking"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.wagon_tracking_path(conn, :create), wagon_tracking: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Wagon tracking"
    end
  end

  describe "edit wagon_tracking" do
    setup [:create_wagon_tracking]

    test "renders form for editing chosen wagon_tracking", %{
      conn: conn,
      wagon_tracking: wagon_tracking
    } do
      conn = get(conn, Routes.wagon_tracking_path(conn, :edit, wagon_tracking))
      assert html_response(conn, 200) =~ "Edit Wagon tracking"
    end
  end

  describe "update wagon_tracking" do
    setup [:create_wagon_tracking]

    test "redirects when data is valid", %{conn: conn, wagon_tracking: wagon_tracking} do
      conn =
        put(conn, Routes.wagon_tracking_path(conn, :update, wagon_tracking),
          wagon_tracking: @update_attrs
        )

      assert redirected_to(conn) == Routes.wagon_tracking_path(conn, :show, wagon_tracking)

      conn = get(conn, Routes.wagon_tracking_path(conn, :show, wagon_tracking))
      assert html_response(conn, 200) =~ "some updated allocated_to_customer"
    end

    test "renders errors when data is invalid", %{conn: conn, wagon_tracking: wagon_tracking} do
      conn =
        put(conn, Routes.wagon_tracking_path(conn, :update, wagon_tracking),
          wagon_tracking: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Wagon tracking"
    end
  end

  describe "delete wagon_tracking" do
    setup [:create_wagon_tracking]

    test "deletes chosen wagon_tracking", %{conn: conn, wagon_tracking: wagon_tracking} do
      conn = delete(conn, Routes.wagon_tracking_path(conn, :delete, wagon_tracking))
      assert redirected_to(conn) == Routes.wagon_tracking_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.wagon_tracking_path(conn, :show, wagon_tracking))
      end
    end
  end

  defp create_wagon_tracking(_) do
    wagon_tracking = fixture(:wagon_tracking)
    %{wagon_tracking: wagon_tracking}
  end
end
