defmodule Rms.TrainRoutesTest do
  use Rms.DataCase

  alias Rms.TrainRoutes

  describe "tbl_train_routes" do
    alias Rms.TrainRoutes.TrainRoute

    @valid_attrs %{
      code: "some code",
      description: "some description",
      destination_station: "some destination_station",
      distance: "some distance",
      operator: "some operator",
      origin_station: "some origin_station",
      status: "some status",
      transport_type: "some transport_type"
    }
    @update_attrs %{
      code: "some updated code",
      description: "some updated description",
      destination_station: "some updated destination_station",
      distance: "some updated distance",
      operator: "some updated operator",
      origin_station: "some updated origin_station",
      status: "some updated status",
      transport_type: "some updated transport_type"
    }
    @invalid_attrs %{
      code: nil,
      description: nil,
      destination_station: nil,
      distance: nil,
      operator: nil,
      origin_station: nil,
      status: nil,
      transport_type: nil
    }

    def train_route_fixture(attrs \\ %{}) do
      {:ok, train_route} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TrainRoutes.create_train_route()

      train_route
    end

    test "list_tbl_train_routes/0 returns all tbl_train_routes" do
      train_route = train_route_fixture()
      assert TrainRoutes.list_tbl_train_routes() == [train_route]
    end

    test "get_train_route!/1 returns the train_route with given id" do
      train_route = train_route_fixture()
      assert TrainRoutes.get_train_route!(train_route.id) == train_route
    end

    test "create_train_route/1 with valid data creates a train_route" do
      assert {:ok, %TrainRoute{} = train_route} = TrainRoutes.create_train_route(@valid_attrs)
      assert train_route.code == "some code"
      assert train_route.description == "some description"
      assert train_route.destination_station == "some destination_station"
      assert train_route.distance == "some distance"
      assert train_route.operator == "some operator"
      assert train_route.origin_station == "some origin_station"
      assert train_route.status == "some status"
      assert train_route.transport_type == "some transport_type"
    end

    test "create_train_route/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TrainRoutes.create_train_route(@invalid_attrs)
    end

    test "update_train_route/2 with valid data updates the train_route" do
      train_route = train_route_fixture()

      assert {:ok, %TrainRoute{} = train_route} =
               TrainRoutes.update_train_route(train_route, @update_attrs)

      assert train_route.code == "some updated code"
      assert train_route.description == "some updated description"
      assert train_route.destination_station == "some updated destination_station"
      assert train_route.distance == "some updated distance"
      assert train_route.operator == "some updated operator"
      assert train_route.origin_station == "some updated origin_station"
      assert train_route.status == "some updated status"
      assert train_route.transport_type == "some updated transport_type"
    end

    test "update_train_route/2 with invalid data returns error changeset" do
      train_route = train_route_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TrainRoutes.update_train_route(train_route, @invalid_attrs)

      assert train_route == TrainRoutes.get_train_route!(train_route.id)
    end

    test "delete_train_route/1 deletes the train_route" do
      train_route = train_route_fixture()
      assert {:ok, %TrainRoute{}} = TrainRoutes.delete_train_route(train_route)
      assert_raise Ecto.NoResultsError, fn -> TrainRoutes.get_train_route!(train_route.id) end
    end

    test "change_train_route/1 returns a train_route changeset" do
      train_route = train_route_fixture()
      assert %Ecto.Changeset{} = TrainRoutes.change_train_route(train_route)
    end
  end
end
