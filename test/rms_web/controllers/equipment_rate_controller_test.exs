defmodule RmsWeb.EquipmentRateControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{rate: "120.5", status: "some status", year: "some year"}
  @update_attrs %{rate: "456.7", status: "some updated status", year: "some updated year"}
  @invalid_attrs %{rate: nil, status: nil, year: nil}

  def fixture(:equipment_rate) do
    {:ok, equipment_rate} = SystemUtilities.create_equipment_rate(@create_attrs)
    equipment_rate
  end

  describe "index" do
    test "lists all tbl_equipment_rates", %{conn: conn} do
      conn = get(conn, Routes.equipment_rate_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl equipment rates"
    end
  end

  describe "new equipment_rate" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.equipment_rate_path(conn, :new))
      assert html_response(conn, 200) =~ "New Equipment rate"
    end
  end

  describe "create equipment_rate" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.equipment_rate_path(conn, :create), equipment_rate: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.equipment_rate_path(conn, :show, id)

      conn = get(conn, Routes.equipment_rate_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Equipment rate"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.equipment_rate_path(conn, :create), equipment_rate: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Equipment rate"
    end
  end

  describe "edit equipment_rate" do
    setup [:create_equipment_rate]

    test "renders form for editing chosen equipment_rate", %{
      conn: conn,
      equipment_rate: equipment_rate
    } do
      conn = get(conn, Routes.equipment_rate_path(conn, :edit, equipment_rate))
      assert html_response(conn, 200) =~ "Edit Equipment rate"
    end
  end

  describe "update equipment_rate" do
    setup [:create_equipment_rate]

    test "redirects when data is valid", %{conn: conn, equipment_rate: equipment_rate} do
      conn =
        put(conn, Routes.equipment_rate_path(conn, :update, equipment_rate),
          equipment_rate: @update_attrs
        )

      assert redirected_to(conn) == Routes.equipment_rate_path(conn, :show, equipment_rate)

      conn = get(conn, Routes.equipment_rate_path(conn, :show, equipment_rate))
      assert html_response(conn, 200) =~ "some updated status"
    end

    test "renders errors when data is invalid", %{conn: conn, equipment_rate: equipment_rate} do
      conn =
        put(conn, Routes.equipment_rate_path(conn, :update, equipment_rate),
          equipment_rate: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Equipment rate"
    end
  end

  describe "delete equipment_rate" do
    setup [:create_equipment_rate]

    test "deletes chosen equipment_rate", %{conn: conn, equipment_rate: equipment_rate} do
      conn = delete(conn, Routes.equipment_rate_path(conn, :delete, equipment_rate))
      assert redirected_to(conn) == Routes.equipment_rate_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.equipment_rate_path(conn, :show, equipment_rate))
      end
    end
  end

  defp create_equipment_rate(_) do
    equipment_rate = fixture(:equipment_rate)
    %{equipment_rate: equipment_rate}
  end
end
