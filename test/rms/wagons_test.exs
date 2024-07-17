defmodule Rms.WagonsTest do
  use Rms.DataCase

  alias Rms.Wagons

  describe "tbl_wagon" do
    alias Rms.Wagons.Wagon

    @valid_attrs %{code: "some code", description: "some description", status: "some status"}
    @update_attrs %{
      code: "some updated code",
      description: "some updated description",
      status: "some updated status"
    }
    @invalid_attrs %{code: nil, description: nil, status: nil}

    def wagon_fixture(attrs \\ %{}) do
      {:ok, wagon} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Wagons.create_wagon()

      wagon
    end

    test "list_tbl_wagon/0 returns all tbl_wagon" do
      wagon = wagon_fixture()
      assert Wagons.list_tbl_wagon() == [wagon]
    end

    test "get_wagon!/1 returns the wagon with given id" do
      wagon = wagon_fixture()
      assert Wagons.get_wagon!(wagon.id) == wagon
    end

    test "create_wagon/1 with valid data creates a wagon" do
      assert {:ok, %Wagon{} = wagon} = Wagons.create_wagon(@valid_attrs)
      assert wagon.code == "some code"
      assert wagon.description == "some description"
      assert wagon.status == "some status"
    end

    test "create_wagon/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Wagons.create_wagon(@invalid_attrs)
    end

    test "update_wagon/2 with valid data updates the wagon" do
      wagon = wagon_fixture()
      assert {:ok, %Wagon{} = wagon} = Wagons.update_wagon(wagon, @update_attrs)
      assert wagon.code == "some updated code"
      assert wagon.description == "some updated description"
      assert wagon.status == "some updated status"
    end

    test "update_wagon/2 with invalid data returns error changeset" do
      wagon = wagon_fixture()
      assert {:error, %Ecto.Changeset{}} = Wagons.update_wagon(wagon, @invalid_attrs)
      assert wagon == Wagons.get_wagon!(wagon.id)
    end

    test "delete_wagon/1 deletes the wagon" do
      wagon = wagon_fixture()
      assert {:ok, %Wagon{}} = Wagons.delete_wagon(wagon)
      assert_raise Ecto.NoResultsError, fn -> Wagons.get_wagon!(wagon.id) end
    end

    test "change_wagon/1 returns a wagon changeset" do
      wagon = wagon_fixture()
      assert %Ecto.Changeset{} = Wagons.change_wagon(wagon)
    end
  end

  describe "tbl_wagon_type" do
    alias Rms.Wagons.WagonType

    @valid_attrs %{
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

    def wagon_type_fixture(attrs \\ %{}) do
      {:ok, wagon_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Wagons.create_wagon_type()

      wagon_type
    end

    test "list_tbl_wagon_type/0 returns all tbl_wagon_type" do
      wagon_type = wagon_type_fixture()
      assert Wagons.list_tbl_wagon_type() == [wagon_type]
    end

    test "get_wagon_type!/1 returns the wagon_type with given id" do
      wagon_type = wagon_type_fixture()
      assert Wagons.get_wagon_type!(wagon_type.id) == wagon_type
    end

    test "create_wagon_type/1 with valid data creates a wagon_type" do
      assert {:ok, %WagonType{} = wagon_type} = Wagons.create_wagon_type(@valid_attrs)
      assert wagon_type.capacity == "some capacity"
      assert wagon_type.code == "some code"
      assert wagon_type.description == "some description"
      assert wagon_type.status == "some status"
      assert wagon_type.type == "some type"
      assert wagon_type.weight == "some weight"
    end

    test "create_wagon_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Wagons.create_wagon_type(@invalid_attrs)
    end

    test "update_wagon_type/2 with valid data updates the wagon_type" do
      wagon_type = wagon_type_fixture()

      assert {:ok, %WagonType{} = wagon_type} =
               Wagons.update_wagon_type(wagon_type, @update_attrs)

      assert wagon_type.capacity == "some updated capacity"
      assert wagon_type.code == "some updated code"
      assert wagon_type.description == "some updated description"
      assert wagon_type.status == "some updated status"
      assert wagon_type.type == "some updated type"
      assert wagon_type.weight == "some updated weight"
    end

    test "update_wagon_type/2 with invalid data returns error changeset" do
      wagon_type = wagon_type_fixture()
      assert {:error, %Ecto.Changeset{}} = Wagons.update_wagon_type(wagon_type, @invalid_attrs)
      assert wagon_type == Wagons.get_wagon_type!(wagon_type.id)
    end

    test "delete_wagon_type/1 deletes the wagon_type" do
      wagon_type = wagon_type_fixture()
      assert {:ok, %WagonType{}} = Wagons.delete_wagon_type(wagon_type)
      assert_raise Ecto.NoResultsError, fn -> Wagons.get_wagon_type!(wagon_type.id) end
    end

    test "change_wagon_type/1 returns a wagon_type changeset" do
      wagon_type = wagon_type_fixture()
      assert %Ecto.Changeset{} = Wagons.change_wagon_type(wagon_type)
    end
  end
end
