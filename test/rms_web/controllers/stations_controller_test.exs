defmodule RmsWeb.StationsControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Station

  @create_attrs %{
    acronym: "some acronym",
    description: "some description",
    station_id: "some station_id"
  }
  @update_attrs %{
    acronym: "some updated acronym",
    description: "some updated description",
    station_id: "some updated station_id"
  }
  @invalid_attrs %{acronym: nil, description: nil, station_id: nil}

  def fixture(:stations) do
    {:ok, stations} = Station.create_stations(@create_attrs)
    stations
  end

  describe "index" do
    test "lists all tbl_stations", %{conn: conn} do
      conn = get(conn, Routes.stations_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl stations"
    end
  end

  describe "new stations" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.stations_path(conn, :new))
      assert html_response(conn, 200) =~ "New Stations"
    end
  end

  describe "create stations" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.stations_path(conn, :create), stations: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.stations_path(conn, :show, id)

      conn = get(conn, Routes.stations_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Stations"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.stations_path(conn, :create), stations: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Stations"
    end
  end

  describe "edit stations" do
    setup [:create_stations]

    test "renders form for editing chosen stations", %{conn: conn, stations: stations} do
      conn = get(conn, Routes.stations_path(conn, :edit, stations))
      assert html_response(conn, 200) =~ "Edit Stations"
    end
  end

  describe "update stations" do
    setup [:create_stations]

    test "redirects when data is valid", %{conn: conn, stations: stations} do
      conn = put(conn, Routes.stations_path(conn, :update, stations), stations: @update_attrs)
      assert redirected_to(conn) == Routes.stations_path(conn, :show, stations)

      conn = get(conn, Routes.stations_path(conn, :show, stations))
      assert html_response(conn, 200) =~ "some updated acronym"
    end

    test "renders errors when data is invalid", %{conn: conn, stations: stations} do
      conn = put(conn, Routes.stations_path(conn, :update, stations), stations: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Stations"
    end
  end

  describe "delete stations" do
    setup [:create_stations]

    test "deletes chosen stations", %{conn: conn, stations: stations} do
      conn = delete(conn, Routes.stations_path(conn, :delete, stations))
      assert redirected_to(conn) == Routes.stations_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.stations_path(conn, :show, stations))
      end
    end
  end

  defp create_stations(_) do
    stations = fixture(:stations)
    %{stations: stations}
  end
end
