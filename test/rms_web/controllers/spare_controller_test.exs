defmodule RmsWeb.SpareControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{code: "some code", description: "some description"}
  @update_attrs %{code: "some updated code", description: "some updated description"}
  @invalid_attrs %{code: nil, description: nil}

  def fixture(:spare) do
    {:ok, spare} = SystemUtilities.create_spare(@create_attrs)
    spare
  end

  describe "index" do
    test "lists all tbl_spares", %{conn: conn} do
      conn = get(conn, Routes.spare_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl spares"
    end
  end

  describe "new spare" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.spare_path(conn, :new))
      assert html_response(conn, 200) =~ "New Spare"
    end
  end

  describe "create spare" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.spare_path(conn, :create), spare: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.spare_path(conn, :show, id)

      conn = get(conn, Routes.spare_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Spare"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.spare_path(conn, :create), spare: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Spare"
    end
  end

  describe "edit spare" do
    setup [:create_spare]

    test "renders form for editing chosen spare", %{conn: conn, spare: spare} do
      conn = get(conn, Routes.spare_path(conn, :edit, spare))
      assert html_response(conn, 200) =~ "Edit Spare"
    end
  end

  describe "update spare" do
    setup [:create_spare]

    test "redirects when data is valid", %{conn: conn, spare: spare} do
      conn = put(conn, Routes.spare_path(conn, :update, spare), spare: @update_attrs)
      assert redirected_to(conn) == Routes.spare_path(conn, :show, spare)

      conn = get(conn, Routes.spare_path(conn, :show, spare))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, spare: spare} do
      conn = put(conn, Routes.spare_path(conn, :update, spare), spare: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Spare"
    end
  end

  describe "delete spare" do
    setup [:create_spare]

    test "deletes chosen spare", %{conn: conn, spare: spare} do
      conn = delete(conn, Routes.spare_path(conn, :delete, spare))
      assert redirected_to(conn) == Routes.spare_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.spare_path(conn, :show, spare))
      end
    end
  end

  defp create_spare(_) do
    spare = fixture(:spare)
    %{spare: spare}
  end
end
