defmodule RmsWeb.LocoDriverControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Locomotives

  @create_attrs %{status: "some status", user_id: "some user_id"}
  @update_attrs %{status: "some updated status", user_id: "some updated user_id"}
  @invalid_attrs %{status: nil, user_id: nil}

  def fixture(:loco_driver) do
    {:ok, loco_driver} = Locomotives.create_loco_driver(@create_attrs)
    loco_driver
  end

  describe "index" do
    test "lists all tbl_loco_driver", %{conn: conn} do
      conn = get(conn, Routes.loco_driver_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl loco driver"
    end
  end

  describe "new loco_driver" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.loco_driver_path(conn, :new))
      assert html_response(conn, 200) =~ "New Loco driver"
    end
  end

  describe "create loco_driver" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.loco_driver_path(conn, :create), loco_driver: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.loco_driver_path(conn, :show, id)

      conn = get(conn, Routes.loco_driver_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Loco driver"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.loco_driver_path(conn, :create), loco_driver: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Loco driver"
    end
  end

  describe "edit loco_driver" do
    setup [:create_loco_driver]

    test "renders form for editing chosen loco_driver", %{conn: conn, loco_driver: loco_driver} do
      conn = get(conn, Routes.loco_driver_path(conn, :edit, loco_driver))
      assert html_response(conn, 200) =~ "Edit Loco driver"
    end
  end

  describe "update loco_driver" do
    setup [:create_loco_driver]

    test "redirects when data is valid", %{conn: conn, loco_driver: loco_driver} do
      conn =
        put(conn, Routes.loco_driver_path(conn, :update, loco_driver), loco_driver: @update_attrs)

      assert redirected_to(conn) == Routes.loco_driver_path(conn, :show, loco_driver)

      conn = get(conn, Routes.loco_driver_path(conn, :show, loco_driver))
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{conn: conn, loco_driver: loco_driver} do
      conn =
        put(conn, Routes.loco_driver_path(conn, :update, loco_driver), loco_driver: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Loco driver"
    end
  end

  describe "delete loco_driver" do
    setup [:create_loco_driver]

    test "deletes chosen loco_driver", %{conn: conn, loco_driver: loco_driver} do
      conn = delete(conn, Routes.loco_driver_path(conn, :delete, loco_driver))
      assert redirected_to(conn) == Routes.loco_driver_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.loco_driver_path(conn, :show, loco_driver))
      end
    end
  end

  defp create_loco_driver(_) do
    loco_driver = fixture(:loco_driver)
    %{loco_driver: loco_driver}
  end
end
