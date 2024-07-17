defmodule Rms.CommoditiesTest do
  use Rms.DataCase

  alias Rms.Commodities

  describe "tbl_commodity" do
    alias Rms.Commodities.Commodity

    @valid_attrs %{
      code: "some code",
      commodity_group: "some commodity_group",
      description: "some description",
      is_container: "some is_container",
      status: "some status"
    }
    @update_attrs %{
      code: "some updated code",
      commodity_group: "some updated commodity_group",
      description: "some updated description",
      is_container: "some updated is_container",
      status: "some updated status"
    }
    @invalid_attrs %{
      code: nil,
      commodity_group: nil,
      description: nil,
      is_container: nil,
      status: nil
    }

    def commodity_fixture(attrs \\ %{}) do
      {:ok, commodity} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Commodities.create_commodity()

      commodity
    end

    test "list_tbl_commodity/0 returns all tbl_commodity" do
      commodity = commodity_fixture()
      assert Commodities.list_tbl_commodity() == [commodity]
    end

    test "get_commodity!/1 returns the commodity with given id" do
      commodity = commodity_fixture()
      assert Commodities.get_commodity!(commodity.id) == commodity
    end

    test "create_commodity/1 with valid data creates a commodity" do
      assert {:ok, %Commodity{} = commodity} = Commodities.create_commodity(@valid_attrs)
      assert commodity.code == "some code"
      assert commodity.commodity_group == "some commodity_group"
      assert commodity.description == "some description"
      assert commodity.is_container == "some is_container"
      assert commodity.status == "some status"
    end

    test "create_commodity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Commodities.create_commodity(@invalid_attrs)
    end

    test "update_commodity/2 with valid data updates the commodity" do
      commodity = commodity_fixture()

      assert {:ok, %Commodity{} = commodity} =
               Commodities.update_commodity(commodity, @update_attrs)

      assert commodity.code == "some updated code"
      assert commodity.commodity_group == "some updated commodity_group"
      assert commodity.description == "some updated description"
      assert commodity.is_container == "some updated is_container"
      assert commodity.status == "some updated status"
    end

    test "update_commodity/2 with invalid data returns error changeset" do
      commodity = commodity_fixture()
      assert {:error, %Ecto.Changeset{}} = Commodities.update_commodity(commodity, @invalid_attrs)
      assert commodity == Commodities.get_commodity!(commodity.id)
    end

    test "delete_commodity/1 deletes the commodity" do
      commodity = commodity_fixture()
      assert {:ok, %Commodity{}} = Commodities.delete_commodity(commodity)
      assert_raise Ecto.NoResultsError, fn -> Commodities.get_commodity!(commodity.id) end
    end

    test "change_commodity/1 returns a commodity changeset" do
      commodity = commodity_fixture()
      assert %Ecto.Changeset{} = Commodities.change_commodity(commodity)
    end
  end

  describe "tbl_commodity_group" do
    alias Rms.Commodities.CommodityGroup

    @valid_attrs %{code: "some code", description: "some description", status: "some status"}
    @update_attrs %{
      code: "some updated code",
      description: "some updated description",
      status: "some updated status"
    }
    @invalid_attrs %{code: nil, description: nil, status: nil}

    def commodity_group_fixture(attrs \\ %{}) do
      {:ok, commodity_group} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Commodities.create_commodity_group()

      commodity_group
    end

    test "list_tbl_commodity_group/0 returns all tbl_commodity_group" do
      commodity_group = commodity_group_fixture()
      assert Commodities.list_tbl_commodity_group() == [commodity_group]
    end

    test "get_commodity_group!/1 returns the commodity_group with given id" do
      commodity_group = commodity_group_fixture()
      assert Commodities.get_commodity_group!(commodity_group.id) == commodity_group
    end

    test "create_commodity_group/1 with valid data creates a commodity_group" do
      assert {:ok, %CommodityGroup{} = commodity_group} =
               Commodities.create_commodity_group(@valid_attrs)

      assert commodity_group.code == "some code"
      assert commodity_group.description == "some description"
      assert commodity_group.status == "some status"
    end

    test "create_commodity_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Commodities.create_commodity_group(@invalid_attrs)
    end

    test "update_commodity_group/2 with valid data updates the commodity_group" do
      commodity_group = commodity_group_fixture()

      assert {:ok, %CommodityGroup{} = commodity_group} =
               Commodities.update_commodity_group(commodity_group, @update_attrs)

      assert commodity_group.code == "some updated code"
      assert commodity_group.description == "some updated description"
      assert commodity_group.status == "some updated status"
    end

    test "update_commodity_group/2 with invalid data returns error changeset" do
      commodity_group = commodity_group_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Commodities.update_commodity_group(commodity_group, @invalid_attrs)

      assert commodity_group == Commodities.get_commodity_group!(commodity_group.id)
    end

    test "delete_commodity_group/1 deletes the commodity_group" do
      commodity_group = commodity_group_fixture()
      assert {:ok, %CommodityGroup{}} = Commodities.delete_commodity_group(commodity_group)

      assert_raise Ecto.NoResultsError, fn ->
        Commodities.get_commodity_group!(commodity_group.id)
      end
    end

    test "change_commodity_group/1 returns a commodity_group changeset" do
      commodity_group = commodity_group_fixture()
      assert %Ecto.Changeset{} = Commodities.change_commodity_group(commodity_group)
    end
  end
end
