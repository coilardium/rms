defmodule RmsWeb.WagonControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Wagons

  @create_attrs %{code: "some code", description: "some description", status: "some status"}
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    status: "some updated status"
  }
  @invalid_attrs %{code: nil, description: nil, status: nil}

  def fixture(:wagon) do
    {:ok, wagon} = Wagons.create_wagon(@create_attrs)
    wagon
  end

  describe "index" do
    test "lists all tbl_wagon", %{conn: conn} do
      conn = get(conn, Routes.wagon_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl wagon"
    end
  end

  describe "new wagon" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.wagon_path(conn, :new))
      assert html_response(conn, 200) =~ "New Wagon"
    end
  end

  describe "create wagon" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.wagon_path(conn, :create), wagon: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.wagon_path(conn, :show, id)

      conn = get(conn, Routes.wagon_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Wagon"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.wagon_path(conn, :create), wagon: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Wagon"
    end
  end

  describe "edit wagon" do
    setup [:create_wagon]

    test "renders form for editing chosen wagon", %{conn: conn, wagon: wagon} do
      conn = get(conn, Routes.wagon_path(conn, :edit, wagon))
      assert html_response(conn, 200) =~ "Edit Wagon"
    end
  end

  describe "update wagon" do
    setup [:create_wagon]

    test "redirects when data is valid", %{conn: conn, wagon: wagon} do
      conn = put(conn, Routes.wagon_path(conn, :update, wagon), wagon: @update_attrs)
      assert redirected_to(conn) == Routes.wagon_path(conn, :show, wagon)

      conn = get(conn, Routes.wagon_path(conn, :show, wagon))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, wagon: wagon} do
      conn = put(conn, Routes.wagon_path(conn, :update, wagon), wagon: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Wagon"
    end
  end

  describe "delete wagon" do
    setup [:create_wagon]

    test "deletes chosen wagon", %{conn: conn, wagon: wagon} do
      conn = delete(conn, Routes.wagon_path(conn, :delete, wagon))
      assert redirected_to(conn) == Routes.wagon_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.wagon_path(conn, :show, wagon))
      end
    end
  end

  defp create_wagon(_) do
    wagon = fixture(:wagon)
    %{wagon: wagon}
  end
end
