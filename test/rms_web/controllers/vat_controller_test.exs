defmodule RmsWeb.VatControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Vats

  @create_attrs %{rate: "some rate", status: "some status"}
  @update_attrs %{rate: "some updated rate", status: "some updated status"}
  @invalid_attrs %{rate: nil, status: nil}

  def fixture(:vat) do
    {:ok, vat} = Vats.create_vat(@create_attrs)
    vat
  end

  describe "index" do
    test "lists all tbl_vat", %{conn: conn} do
      conn = get(conn, Routes.vat_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl vat"
    end
  end

  describe "new vat" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.vat_path(conn, :new))
      assert html_response(conn, 200) =~ "New Vat"
    end
  end

  describe "create vat" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.vat_path(conn, :create), vat: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.vat_path(conn, :show, id)

      conn = get(conn, Routes.vat_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Vat"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.vat_path(conn, :create), vat: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Vat"
    end
  end

  describe "edit vat" do
    setup [:create_vat]

    test "renders form for editing chosen vat", %{conn: conn, vat: vat} do
      conn = get(conn, Routes.vat_path(conn, :edit, vat))
      assert html_response(conn, 200) =~ "Edit Vat"
    end
  end

  describe "update vat" do
    setup [:create_vat]

    test "redirects when data is valid", %{conn: conn, vat: vat} do
      conn = put(conn, Routes.vat_path(conn, :update, vat), vat: @update_attrs)
      assert redirected_to(conn) == Routes.vat_path(conn, :show, vat)

      conn = get(conn, Routes.vat_path(conn, :show, vat))
      assert html_response(conn, 200) =~ "some updated rate"
    end

    test "renders errors when data is invalid", %{conn: conn, vat: vat} do
      conn = put(conn, Routes.vat_path(conn, :update, vat), vat: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Vat"
    end
  end

  describe "delete vat" do
    setup [:create_vat]

    test "deletes chosen vat", %{conn: conn, vat: vat} do
      conn = delete(conn, Routes.vat_path(conn, :delete, vat))
      assert redirected_to(conn) == Routes.vat_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.vat_path(conn, :show, vat))
      end
    end
  end

  defp create_vat(_) do
    vat = fixture(:vat)
    %{vat: vat}
  end
end
