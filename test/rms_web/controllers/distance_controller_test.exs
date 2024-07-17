defmodule RmsWeb.DistanceControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{destin: "some destin", distance: "120.5", station_orig: "some station_orig"}
  @update_attrs %{
    destin: "some updated destin",
    distance: "456.7",
    station_orig: "some updated station_orig"
  }
  @invalid_attrs %{destin: nil, distance: nil, station_orig: nil}

  def fixture(:distance) do
    {:ok, distance} = SystemUtilities.create_distance(@create_attrs)
    distance
  end

  describe "index" do
    test "lists all tbl_distance", %{conn: conn} do
      conn = get(conn, Routes.distance_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl distance"
    end
  end

  describe "new distance" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.distance_path(conn, :new))
      assert html_response(conn, 200) =~ "New Distance"
    end
  end

  describe "create distance" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.distance_path(conn, :create), distance: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.distance_path(conn, :show, id)

      conn = get(conn, Routes.distance_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Distance"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.distance_path(conn, :create), distance: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Distance"
    end
  end

  describe "edit distance" do
    setup [:create_distance]

    test "renders form for editing chosen distance", %{conn: conn, distance: distance} do
      conn = get(conn, Routes.distance_path(conn, :edit, distance))
      assert html_response(conn, 200) =~ "Edit Distance"
    end
  end

  describe "update distance" do
    setup [:create_distance]

    test "redirects when data is valid", %{conn: conn, distance: distance} do
      conn = put(conn, Routes.distance_path(conn, :update, distance), distance: @update_attrs)
      assert redirected_to(conn) == Routes.distance_path(conn, :show, distance)

      conn = get(conn, Routes.distance_path(conn, :show, distance))
      assert html_response(conn, 200) =~ "some updated destin"
    end

    test "renders errors when data is invalid", %{conn: conn, distance: distance} do
      conn = put(conn, Routes.distance_path(conn, :update, distance), distance: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Distance"
    end
  end

  describe "delete distance" do
    setup [:create_distance]

    test "deletes chosen distance", %{conn: conn, distance: distance} do
      conn = delete(conn, Routes.distance_path(conn, :delete, distance))
      assert redirected_to(conn) == Routes.distance_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.distance_path(conn, :show, distance))
      end
    end
  end

  defp create_distance(_) do
    distance = fixture(:distance)
    %{distance: distance}
  end
end
