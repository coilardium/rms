defmodule RmsWeb.SurchageControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Surchages

  @create_attrs %{code: "some code", description: "some description", status: "some status"}
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    status: "some updated status"
  }
  @invalid_attrs %{code: nil, description: nil, status: nil}

  def fixture(:surchage) do
    {:ok, surchage} = Surchages.create_surchage(@create_attrs)
    surchage
  end

  describe "index" do
    test "lists all tbl_surcharge", %{conn: conn} do
      conn = get(conn, Routes.surchage_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl surcharge"
    end
  end

  describe "new surchage" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.surchage_path(conn, :new))
      assert html_response(conn, 200) =~ "New Surchage"
    end
  end

  describe "create surchage" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.surchage_path(conn, :create), surchage: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.surchage_path(conn, :show, id)

      conn = get(conn, Routes.surchage_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Surchage"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.surchage_path(conn, :create), surchage: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Surchage"
    end
  end

  describe "edit surchage" do
    setup [:create_surchage]

    test "renders form for editing chosen surchage", %{conn: conn, surchage: surchage} do
      conn = get(conn, Routes.surchage_path(conn, :edit, surchage))
      assert html_response(conn, 200) =~ "Edit Surchage"
    end
  end

  describe "update surchage" do
    setup [:create_surchage]

    test "redirects when data is valid", %{conn: conn, surchage: surchage} do
      conn = put(conn, Routes.surchage_path(conn, :update, surchage), surchage: @update_attrs)
      assert redirected_to(conn) == Routes.surchage_path(conn, :show, surchage)

      conn = get(conn, Routes.surchage_path(conn, :show, surchage))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, surchage: surchage} do
      conn = put(conn, Routes.surchage_path(conn, :update, surchage), surchage: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Surchage"
    end
  end

  describe "delete surchage" do
    setup [:create_surchage]

    test "deletes chosen surchage", %{conn: conn, surchage: surchage} do
      conn = delete(conn, Routes.surchage_path(conn, :delete, surchage))
      assert redirected_to(conn) == Routes.surchage_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.surchage_path(conn, :show, surchage))
      end
    end
  end

  defp create_surchage(_) do
    surchage = fixture(:surchage)
    %{surchage: surchage}
  end
end
