defmodule RmsWeb.WagonTypeControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Wagons

  @create_attrs %{
    capacity: "some capacity",
    code: "some code",
    description: "some description",
    status: "some status",
    type: "some type",
    weight: "some weight"
  }
  @update_attrs %{
    capacity: "some updated capacity",
    code: "some updated code",
    description: "some updated description",
    status: "some updated status",
    type: "some updated type",
    weight: "some updated weight"
  }
  @invalid_attrs %{
    capacity: nil,
    code: nil,
    description: nil,
    status: nil,
    type: nil,
    weight: nil
  }

  def fixture(:wagon_type) do
    {:ok, wagon_type} = Wagons.create_wagon_type(@create_attrs)
    wagon_type
  end

  describe "index" do
    test "lists all tbl_wagon_type", %{conn: conn} do
      conn = get(conn, Routes.wagon_type_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl wagon type"
    end
  end

  describe "new wagon_type" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.wagon_type_path(conn, :new))
      assert html_response(conn, 200) =~ "New Wagon type"
    end
  end

  describe "create wagon_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.wagon_type_path(conn, :create), wagon_type: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.wagon_type_path(conn, :show, id)

      conn = get(conn, Routes.wagon_type_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Wagon type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.wagon_type_path(conn, :create), wagon_type: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Wagon type"
    end
  end

  describe "edit wagon_type" do
    setup [:create_wagon_type]

    test "renders form for editing chosen wagon_type", %{conn: conn, wagon_type: wagon_type} do
      conn = get(conn, Routes.wagon_type_path(conn, :edit, wagon_type))
      assert html_response(conn, 200) =~ "Edit Wagon type"
    end
  end

  describe "update wagon_type" do
    setup [:create_wagon_type]

    test "redirects when data is valid", %{conn: conn, wagon_type: wagon_type} do
      conn =
        put(conn, Routes.wagon_type_path(conn, :update, wagon_type), wagon_type: @update_attrs)

      assert redirected_to(conn) == Routes.wagon_type_path(conn, :show, wagon_type)

      conn = get(conn, Routes.wagon_type_path(conn, :show, wagon_type))
      assert html_response(conn, 200) =~ "some updated capacity"
    end

    test "renders errors when data is invalid", %{conn: conn, wagon_type: wagon_type} do
      conn =
        put(conn, Routes.wagon_type_path(conn, :update, wagon_type), wagon_type: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Wagon type"
    end
  end

  describe "delete wagon_type" do
    setup [:create_wagon_type]

    test "deletes chosen wagon_type", %{conn: conn, wagon_type: wagon_type} do
      conn = delete(conn, Routes.wagon_type_path(conn, :delete, wagon_type))
      assert redirected_to(conn) == Routes.wagon_type_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.wagon_type_path(conn, :show, wagon_type))
      end
    end
  end

  defp create_wagon_type(_) do
    wagon_type = fixture(:wagon_type)
    %{wagon_type: wagon_type}
  end
end
