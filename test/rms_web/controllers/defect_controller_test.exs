defmodule RmsWeb.DefectControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{code: "some code", description: "some description"}
  @update_attrs %{code: "some updated code", description: "some updated description"}
  @invalid_attrs %{code: nil, description: nil}

  def fixture(:defect) do
    {:ok, defect} = SystemUtilities.create_defect(@create_attrs)
    defect
  end

  describe "index" do
    test "lists all tbl_defects", %{conn: conn} do
      conn = get(conn, Routes.defect_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl defects"
    end
  end

  describe "new defect" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.defect_path(conn, :new))
      assert html_response(conn, 200) =~ "New Defect"
    end
  end

  describe "create defect" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.defect_path(conn, :create), defect: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.defect_path(conn, :show, id)

      conn = get(conn, Routes.defect_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Defect"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.defect_path(conn, :create), defect: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Defect"
    end
  end

  describe "edit defect" do
    setup [:create_defect]

    test "renders form for editing chosen defect", %{conn: conn, defect: defect} do
      conn = get(conn, Routes.defect_path(conn, :edit, defect))
      assert html_response(conn, 200) =~ "Edit Defect"
    end
  end

  describe "update defect" do
    setup [:create_defect]

    test "redirects when data is valid", %{conn: conn, defect: defect} do
      conn = put(conn, Routes.defect_path(conn, :update, defect), defect: @update_attrs)
      assert redirected_to(conn) == Routes.defect_path(conn, :show, defect)

      conn = get(conn, Routes.defect_path(conn, :show, defect))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, defect: defect} do
      conn = put(conn, Routes.defect_path(conn, :update, defect), defect: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Defect"
    end
  end

  describe "delete defect" do
    setup [:create_defect]

    test "deletes chosen defect", %{conn: conn, defect: defect} do
      conn = delete(conn, Routes.defect_path(conn, :delete, defect))
      assert redirected_to(conn) == Routes.defect_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.defect_path(conn, :show, defect))
      end
    end
  end

  defp create_defect(_) do
    defect = fixture(:defect)
    %{defect: defect}
  end
end
