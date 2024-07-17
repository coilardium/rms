defmodule Rms.StationTest do
  use Rms.DataCase

  alias Rms.Station

  describe "tbl_stations" do
    alias Rms.Station.Stations

    @valid_attrs %{
      acronym: "some acronym",
      checker_id: "some checker_id",
      description: "some description",
      integer: "some integer",
      interger: "some interger",
      maker_id: "some maker_id",
      station_id: "some station_id"
    }
    @update_attrs %{
      acronym: "some updated acronym",
      checker_id: "some updated checker_id",
      description: "some updated description",
      integer: "some updated integer",
      interger: "some updated interger",
      maker_id: "some updated maker_id",
      station_id: "some updated station_id"
    }
    @invalid_attrs %{
      acronym: nil,
      checker_id: nil,
      description: nil,
      integer: nil,
      interger: nil,
      maker_id: nil,
      station_id: nil
    }

    def stations_fixture(attrs \\ %{}) do
      {:ok, stations} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Station.create_stations()

      stations
    end

    test "list_tbl_stations/0 returns all tbl_stations" do
      stations = stations_fixture()
      assert Station.list_tbl_stations() == [stations]
    end

    test "get_stations!/1 returns the stations with given id" do
      stations = stations_fixture()
      assert Station.get_stations!(stations.id) == stations
    end

    test "create_stations/1 with valid data creates a stations" do
      assert {:ok, %Stations{} = stations} = Station.create_stations(@valid_attrs)
      assert stations.acronym == "some acronym"
      assert stations.checker_id == "some checker_id"
      assert stations.description == "some description"
      assert stations.integer == "some integer"
      assert stations.interger == "some interger"
      assert stations.maker_id == "some maker_id"
      assert stations.station_id == "some station_id"
    end

    test "create_stations/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Station.create_stations(@invalid_attrs)
    end

    test "update_stations/2 with valid data updates the stations" do
      stations = stations_fixture()
      assert {:ok, %Stations{} = stations} = Station.update_stations(stations, @update_attrs)
      assert stations.acronym == "some updated acronym"
      assert stations.checker_id == "some updated checker_id"
      assert stations.description == "some updated description"
      assert stations.integer == "some updated integer"
      assert stations.interger == "some updated interger"
      assert stations.maker_id == "some updated maker_id"
      assert stations.station_id == "some updated station_id"
    end

    test "update_stations/2 with invalid data returns error changeset" do
      stations = stations_fixture()
      assert {:error, %Ecto.Changeset{}} = Station.update_stations(stations, @invalid_attrs)
      assert stations == Station.get_stations!(stations.id)
    end

    test "delete_stations/1 deletes the stations" do
      stations = stations_fixture()
      assert {:ok, %Stations{}} = Station.delete_stations(stations)
      assert_raise Ecto.NoResultsError, fn -> Station.get_stations!(stations.id) end
    end

    test "change_stations/1 returns a stations changeset" do
      stations = stations_fixture()
      assert %Ecto.Changeset{} = Station.change_stations(stations)
    end
  end

  describe "tbl_stations" do
    alias Rms.Station.Stations

    @valid_attrs %{
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

    def stations_fixture(attrs \\ %{}) do
      {:ok, stations} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Station.create_stations()

      stations
    end

    test "list_tbl_stations/0 returns all tbl_stations" do
      stations = stations_fixture()
      assert Station.list_tbl_stations() == [stations]
    end

    test "get_stations!/1 returns the stations with given id" do
      stations = stations_fixture()
      assert Station.get_stations!(stations.id) == stations
    end

    test "create_stations/1 with valid data creates a stations" do
      assert {:ok, %Stations{} = stations} = Station.create_stations(@valid_attrs)
      assert stations.acronym == "some acronym"
      assert stations.description == "some description"
      assert stations.station_id == "some station_id"
    end

    test "create_stations/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Station.create_stations(@invalid_attrs)
    end

    test "update_stations/2 with valid data updates the stations" do
      stations = stations_fixture()
      assert {:ok, %Stations{} = stations} = Station.update_stations(stations, @update_attrs)
      assert stations.acronym == "some updated acronym"
      assert stations.description == "some updated description"
      assert stations.station_id == "some updated station_id"
    end

    test "update_stations/2 with invalid data returns error changeset" do
      stations = stations_fixture()
      assert {:error, %Ecto.Changeset{}} = Station.update_stations(stations, @invalid_attrs)
      assert stations == Station.get_stations!(stations.id)
    end

    test "delete_stations/1 deletes the stations" do
      stations = stations_fixture()
      assert {:ok, %Stations{}} = Station.delete_stations(stations)
      assert_raise Ecto.NoResultsError, fn -> Station.get_stations!(stations.id) end
    end

    test "change_stations/1 returns a stations changeset" do
      stations = stations_fixture()
      assert %Ecto.Changeset{} = Station.change_stations(stations)
    end
  end
end
