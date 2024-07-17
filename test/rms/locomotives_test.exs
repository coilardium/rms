defmodule Rms.LocomotivesTest do
  use Rms.DataCase

  alias Rms.Locomotives

  describe "tbl_locomotive" do
    alias Rms.Locomotives.Locomotive

    @valid_attrs %{
      description: "some description",
      loco_number: "some loco_number",
      model: "some model",
      status: "some status",
      type_id: "some type_id",
      weight: 120.5
    }
    @update_attrs %{
      description: "some updated description",
      loco_number: "some updated loco_number",
      model: "some updated model",
      status: "some updated status",
      type_id: "some updated type_id",
      weight: 456.7
    }
    @invalid_attrs %{
      description: nil,
      loco_number: nil,
      model: nil,
      status: nil,
      type_id: nil,
      weight: nil
    }

    def locomotive_fixture(attrs \\ %{}) do
      {:ok, locomotive} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Locomotives.create_locomotive()

      locomotive
    end

    test "list_tbl_locomotive/0 returns all tbl_locomotive" do
      locomotive = locomotive_fixture()
      assert Locomotives.list_tbl_locomotive() == [locomotive]
    end

    test "get_locomotive!/1 returns the locomotive with given id" do
      locomotive = locomotive_fixture()
      assert Locomotives.get_locomotive!(locomotive.id) == locomotive
    end

    test "create_locomotive/1 with valid data creates a locomotive" do
      assert {:ok, %Locomotive{} = locomotive} = Locomotives.create_locomotive(@valid_attrs)
      assert locomotive.description == "some description"
      assert locomotive.loco_number == "some loco_number"
      assert locomotive.model == "some model"
      assert locomotive.status == "some status"
      assert locomotive.type_id == "some type_id"
      assert locomotive.weight == 120.5
    end

    test "create_locomotive/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locomotives.create_locomotive(@invalid_attrs)
    end

    test "update_locomotive/2 with valid data updates the locomotive" do
      locomotive = locomotive_fixture()

      assert {:ok, %Locomotive{} = locomotive} =
               Locomotives.update_locomotive(locomotive, @update_attrs)

      assert locomotive.description == "some updated description"
      assert locomotive.loco_number == "some updated loco_number"
      assert locomotive.model == "some updated model"
      assert locomotive.status == "some updated status"
      assert locomotive.type_id == "some updated type_id"
      assert locomotive.weight == 456.7
    end

    test "update_locomotive/2 with invalid data returns error changeset" do
      locomotive = locomotive_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Locomotives.update_locomotive(locomotive, @invalid_attrs)

      assert locomotive == Locomotives.get_locomotive!(locomotive.id)
    end

    test "delete_locomotive/1 deletes the locomotive" do
      locomotive = locomotive_fixture()
      assert {:ok, %Locomotive{}} = Locomotives.delete_locomotive(locomotive)
      assert_raise Ecto.NoResultsError, fn -> Locomotives.get_locomotive!(locomotive.id) end
    end

    test "change_locomotive/1 returns a locomotive changeset" do
      locomotive = locomotive_fixture()
      assert %Ecto.Changeset{} = Locomotives.change_locomotive(locomotive)
    end
  end

  describe "tbl_loco_driver" do
    alias Rms.Locomotives.LocoDriver

    @valid_attrs %{status: "some status", user_id: "some user_id"}
    @update_attrs %{status: "some updated status", user_id: "some updated user_id"}
    @invalid_attrs %{status: nil, user_id: nil}

    def loco_driver_fixture(attrs \\ %{}) do
      {:ok, loco_driver} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Locomotives.create_loco_driver()

      loco_driver
    end

    test "list_tbl_loco_driver/0 returns all tbl_loco_driver" do
      loco_driver = loco_driver_fixture()
      assert Locomotives.list_tbl_loco_driver() == [loco_driver]
    end

    test "get_loco_driver!/1 returns the loco_driver with given id" do
      loco_driver = loco_driver_fixture()
      assert Locomotives.get_loco_driver!(loco_driver.id) == loco_driver
    end

    test "create_loco_driver/1 with valid data creates a loco_driver" do
      assert {:ok, %LocoDriver{} = loco_driver} = Locomotives.create_loco_driver(@valid_attrs)
      assert loco_driver.status == "some status"
      assert loco_driver.user_id == "some user_id"
    end

    test "create_loco_driver/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locomotives.create_loco_driver(@invalid_attrs)
    end

    test "update_loco_driver/2 with valid data updates the loco_driver" do
      loco_driver = loco_driver_fixture()

      assert {:ok, %LocoDriver{} = loco_driver} =
               Locomotives.update_loco_driver(loco_driver, @update_attrs)

      assert loco_driver.status == "some updated status"
      assert loco_driver.user_id == "some updated user_id"
    end

    test "update_loco_driver/2 with invalid data returns error changeset" do
      loco_driver = loco_driver_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Locomotives.update_loco_driver(loco_driver, @invalid_attrs)

      assert loco_driver == Locomotives.get_loco_driver!(loco_driver.id)
    end

    test "delete_loco_driver/1 deletes the loco_driver" do
      loco_driver = loco_driver_fixture()
      assert {:ok, %LocoDriver{}} = Locomotives.delete_loco_driver(loco_driver)
      assert_raise Ecto.NoResultsError, fn -> Locomotives.get_loco_driver!(loco_driver.id) end
    end

    test "change_loco_driver/1 returns a loco_driver changeset" do
      loco_driver = loco_driver_fixture()
      assert %Ecto.Changeset{} = Locomotives.change_loco_driver(loco_driver)
    end
  end

  describe "tbl_locomotive_type" do
    alias Rms.Locomotives.LocomotiveType

    @valid_attrs %{code: "some code", description: "some description", status: "some status"}
    @update_attrs %{
      code: "some updated code",
      description: "some updated description",
      status: "some updated status"
    }
    @invalid_attrs %{code: nil, description: nil, status: nil}

    def locomotive_type_fixture(attrs \\ %{}) do
      {:ok, locomotive_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Locomotives.create_locomotive_type()

      locomotive_type
    end

    test "list_tbl_locomotive_type/0 returns all tbl_locomotive_type" do
      locomotive_type = locomotive_type_fixture()
      assert Locomotives.list_tbl_locomotive_type() == [locomotive_type]
    end

    test "get_locomotive_type!/1 returns the locomotive_type with given id" do
      locomotive_type = locomotive_type_fixture()
      assert Locomotives.get_locomotive_type!(locomotive_type.id) == locomotive_type
    end

    test "create_locomotive_type/1 with valid data creates a locomotive_type" do
      assert {:ok, %LocomotiveType{} = locomotive_type} =
               Locomotives.create_locomotive_type(@valid_attrs)

      assert locomotive_type.code == "some code"
      assert locomotive_type.description == "some description"
      assert locomotive_type.status == "some status"
    end

    test "create_locomotive_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Locomotives.create_locomotive_type(@invalid_attrs)
    end

    test "update_locomotive_type/2 with valid data updates the locomotive_type" do
      locomotive_type = locomotive_type_fixture()

      assert {:ok, %LocomotiveType{} = locomotive_type} =
               Locomotives.update_locomotive_type(locomotive_type, @update_attrs)

      assert locomotive_type.code == "some updated code"
      assert locomotive_type.description == "some updated description"
      assert locomotive_type.status == "some updated status"
    end

    test "update_locomotive_type/2 with invalid data returns error changeset" do
      locomotive_type = locomotive_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Locomotives.update_locomotive_type(locomotive_type, @invalid_attrs)

      assert locomotive_type == Locomotives.get_locomotive_type!(locomotive_type.id)
    end

    test "delete_locomotive_type/1 deletes the locomotive_type" do
      locomotive_type = locomotive_type_fixture()
      assert {:ok, %LocomotiveType{}} = Locomotives.delete_locomotive_type(locomotive_type)

      assert_raise Ecto.NoResultsError, fn ->
        Locomotives.get_locomotive_type!(locomotive_type.id)
      end
    end

    test "change_locomotive_type/1 returns a locomotive_type changeset" do
      locomotive_type = locomotive_type_fixture()
      assert %Ecto.Changeset{} = Locomotives.change_locomotive_type(locomotive_type)
    end
  end
end
