defmodule RmsWeb.EquipmentControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{code: "some code", description: "some description"}
  @update_attrs %{code: "some updated code", description: "some updated description"}
  @invalid_attrs %{code: nil, description: nil}

  def fixture(:equipment) do
    {:ok, equipment} = SystemUtilities.create_equipment(@create_attrs)
    equipment
  end

  describe "index" do
    test "lists all tbl_equipments", %{conn: conn} do
      conn = get(conn, Routes.equipment_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl equipments"
    end
  end

  describe "new equipment" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.equipment_path(conn, :new))
      assert html_response(conn, 200) =~ "New Equipment"
    end
  end

  describe "create equipment" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.equipment_path(conn, :create), equipment: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.equipment_path(conn, :show, id)

      conn = get(conn, Routes.equipment_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Equipment"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.equipment_path(conn, :create), equipment: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Equipment"
    end
  end

  describe "edit equipment" do
    setup [:create_equipment]

    test "renders form for editing chosen equipment", %{conn: conn, equipment: equipment} do
      conn = get(conn, Routes.equipment_path(conn, :edit, equipment))
      assert html_response(conn, 200) =~ "Edit Equipment"
    end
  end

  describe "update equipment" do
    setup [:create_equipment]

    test "redirects when data is valid", %{conn: conn, equipment: equipment} do
      conn = put(conn, Routes.equipment_path(conn, :update, equipment), equipment: @update_attrs)
      assert redirected_to(conn) == Routes.equipment_path(conn, :show, equipment)

      conn = get(conn, Routes.equipment_path(conn, :show, equipment))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, equipment: equipment} do
      conn = put(conn, Routes.equipment_path(conn, :update, equipment), equipment: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Equipment"
    end
  end

  describe "delete equipment" do
    setup [:create_equipment]

    test "deletes chosen equipment", %{conn: conn, equipment: equipment} do
      conn = delete(conn, Routes.equipment_path(conn, :delete, equipment))
      assert redirected_to(conn) == Routes.equipment_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.equipment_path(conn, :show, equipment))
      end
    end
  end

  defp create_equipment(_) do
    equipment = fixture(:equipment)
    %{equipment: equipment}
  end
end
