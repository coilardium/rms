defmodule RmsWeb.SpareFeeControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{amount: "120.5", code: "some code", start_date: ~D[2010-04-17]}
  @update_attrs %{amount: "456.7", code: "some updated code", start_date: ~D[2011-05-18]}
  @invalid_attrs %{amount: nil, code: nil, start_date: nil}

  def fixture(:spare_fee) do
    {:ok, spare_fee} = SystemUtilities.create_spare_fee(@create_attrs)
    spare_fee
  end

  describe "index" do
    test "lists all tbl_spare_fees", %{conn: conn} do
      conn = get(conn, Routes.spare_fee_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl spare fees"
    end
  end

  describe "new spare_fee" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.spare_fee_path(conn, :new))
      assert html_response(conn, 200) =~ "New Spare fee"
    end
  end

  describe "create spare_fee" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.spare_fee_path(conn, :create), spare_fee: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.spare_fee_path(conn, :show, id)

      conn = get(conn, Routes.spare_fee_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Spare fee"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.spare_fee_path(conn, :create), spare_fee: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Spare fee"
    end
  end

  describe "edit spare_fee" do
    setup [:create_spare_fee]

    test "renders form for editing chosen spare_fee", %{conn: conn, spare_fee: spare_fee} do
      conn = get(conn, Routes.spare_fee_path(conn, :edit, spare_fee))
      assert html_response(conn, 200) =~ "Edit Spare fee"
    end
  end

  describe "update spare_fee" do
    setup [:create_spare_fee]

    test "redirects when data is valid", %{conn: conn, spare_fee: spare_fee} do
      conn = put(conn, Routes.spare_fee_path(conn, :update, spare_fee), spare_fee: @update_attrs)
      assert redirected_to(conn) == Routes.spare_fee_path(conn, :show, spare_fee)

      conn = get(conn, Routes.spare_fee_path(conn, :show, spare_fee))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, spare_fee: spare_fee} do
      conn = put(conn, Routes.spare_fee_path(conn, :update, spare_fee), spare_fee: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Spare fee"
    end
  end

  describe "delete spare_fee" do
    setup [:create_spare_fee]

    test "deletes chosen spare_fee", %{conn: conn, spare_fee: spare_fee} do
      conn = delete(conn, Routes.spare_fee_path(conn, :delete, spare_fee))
      assert redirected_to(conn) == Routes.spare_fee_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.spare_fee_path(conn, :show, spare_fee))
      end
    end
  end

  defp create_spare_fee(_) do
    spare_fee = fixture(:spare_fee)
    %{spare_fee: spare_fee}
  end
end
